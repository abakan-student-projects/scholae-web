package ;

import model.Config;
import model.Session;
import haxe.io.Bytes;
import haxe.Serializer;
import model.Job;
import jobs.ScholaeJob;
import jobs.JobQueue;
import jobs.JobMessage;
import model.User;
import sys.db.Types.SBigInt;
import model.Attempt;
import model.CodeforcesTaskTag;
import model.CodeforcesTag;
import codeforces.Problem;
import codeforces.Contest;
import haxe.ds.IntMap;
import model.CodeforcesTask;
import codeforces.ProblemStatistics;
import haxe.ds.StringMap;
import codeforces.ProblemsResponse;
import codeforces.Codeforces;
import haxe.EnumTools;
import haxe.EnumTools.EnumValueTools;
import haxe.Json;
import haxe.Unserializer;
import org.amqp.fast.FastImport.Delivery;
import org.amqp.fast.FastImport.Channel;
import org.amqp.ConnectionParameters;
import org.amqp.fast.neko.AmqpConnection;

class Main {

    private static var cfg: Config;

    public static function main() {

        var cnx = sys.db.Mysql.connect({
            host : "127.0.0.1",
            port : null,
            user : "scholae",
            pass : "scholae",
            database : "scholae",
            socket : null,
        });
        cnx.request("SET NAMES 'utf8';");

        sys.db.Manager.cnx = cnx;
        sys.db.Manager.initialize();

        cfg = { action: null, batchCount: 100, verbose: false };

        var args = Sys.args();
        var argHandler = hxargs.Args.generate([
            @doc("model.Action: updateCodeforcesTasks, updateCodeforcesTasksLevelsAndTypes, updateGymTasks,
            updateTags, updateTaskIdsOnAttempts, updateUsersResults, updateCodeforcesData")
            ["-a", "--action"] => function(action:String) cfg.action = EnumTools.createByName(model.Action, action),

            @doc("Limit number of processing items. Works only for updateGymTasks")
            ["-c", "--count"] => function(count:String) cfg.batchCount = Std.parseInt(count),

            @doc("Enable the verbose mode")
            ["-v", "--verbose"] => function() cfg.verbose=true,

            _ => function(arg:String) throw "Unknown command: " +arg
        ]);

        argHandler.parse(args);

        if (args.length <= 0) {
            Sys.println("Scholae command line tool");
            Sys.println(argHandler.getDoc());
            Sys.exit(0);
        }

        switch (cfg.action) {
            case model.Action.updateCodeforcesTasks: updateCodeforcesTasks();//1
            case model.Action.updateCodeforcesTasksLevelsAndTypes: updateCodeforcesTasksLevelsAndTypes();//3
            case model.Action.updateGymTasks: updateGymTasks(cfg);//2
            case model.Action.updateTags: updateTags();//0
            case model.Action.updateTaskIdsOnAttempts: updateTaskIdsOnAttempts();//4
            case model.Action.updateUsersResults: updateUsersResults();
            case model.Action.updateCodeforcesData: updateCodeforcesData();
        }

        sys.db.Manager.cleanup();
        cnx.close();
    }

    public static function updateCodeforcesTasks() {
        updateCodeForcesTasksByResoponse(Codeforces.getAllProblemsResponse());

    }

    private static inline function getProblemId(contestId: Int, index: String): String {
        return Std.string(contestId) + "::" + index;
    }

    private static function updateCodeForcesTasksByResoponse(response: ProblemsResponse) {
        var statistics: StringMap<ProblemStatistics> =  new StringMap<ProblemStatistics>();

        for (s in response.problemStatistics) {
            statistics.set(getProblemId(s.contestId, s.index), s);
        }

        for (p in response.problems) {
            if (p.type != "PROGRAMMING") continue;
            var t: CodeforcesTask = CodeforcesTask.getOrCreateByCodeforcesProblem(p);
            var s = statistics.get(getProblemId(p.contestId, p.index));
            t.solvedCount = if (s != null) s.solvedCount else 0;
            t.update();
        }
    }

    public static function updateTaskIdsOnAttempts() {
        var isNull:Null<SBigInt> = null;
        var attempts = Attempt.manager.search($taskId == isNull);
        for (attempt in attempts) {
            var d = Json.parse(attempt.description);
            var contestId = Reflect.field(d,"contestId");
            var index = Reflect.field(d.problem,"index");
            var codeforcesTask = CodeforcesTask.manager.select({contestId: contestId, contestIndex: index});
            attempt.task = codeforcesTask;
            attempt.update();
        }
    }

    public static function updateCodeforcesTasksLevelsAndTypes() {

        var contests: IntMap<Contest> = new IntMap<Contest>();
        for (c in Codeforces.getAllContests()) {
            contests.set(c.id, c);
        }

        var tasksByContest: IntMap<Array<CodeforcesTask>> = new IntMap<Array<CodeforcesTask>>();
        var tasks = CodeforcesTask.manager.all();
        for (t in tasks) {
            if (!tasksByContest.exists(t.contestId)) {
                tasksByContest.set(t.contestId, []);
            }
            tasksByContest.get(t.contestId).push(t);
        }

        for (t in tasks) {
            if (cfg.verbose) neko.Lib.println("Task: " + t.toMessage());

            var contest = contests.get(t.contestId);

            if (contest == null) {
                t.lock();
                t.active = false;
                t.update();
                continue;
            }

            if (cfg.verbose) neko.Lib.println("Task contest: " + contest);

            t.type = contest.type;

            if (contest.difficulty != null) {
                var contestSum: Int = Lambda.fold(tasksByContest.get(t.contestId), function(t, sum) { return sum + t.solvedCount;}, 0);
                var contestMiddle = contestSum / Lambda.count(tasksByContest.get(t.contestId));

                if (t.solvedCount < contestMiddle - contestSum / 6) {
                    t.level = Std.int(Math.max(1, contest.difficulty + 1));
                } else if (t.solvedCount > contestMiddle + contestSum / 6) {
                    t.level = Std.int(Math.min(contest.difficulty - 1, 5));
                } else {
                    t.level = contest.difficulty;
                }
            } else {
                t.level =
                        if (t.solvedCount < 100) 5
                        else if (t.solvedCount < 1000) 4
                        else if (t.solvedCount < 5000) 3
                        else if (t.solvedCount < 20000) 2
                        else 1;
            }

            t.update();
        }
    }

    public static function updateGymTasks(cfg: Config) {
        var processed = 0;
        for (c in Codeforces.getGymContests()) {
            if (!CodeforcesTask.doTasksExistForContest(c.id)) {
                trace(c);
                updateCodeForcesTasksByResoponse(Codeforces.getGymProblemsByContest(c));
                processed += 1;
                if (processed >= cfg.batchCount) {
                    break;
                }
            }
        }
    }

    public static function updateTags() {

        var response = Codeforces.getAllProblemsResponse();
        var problemFromResponse: StringMap<Problem> = new StringMap<Problem>();

        for (p in response.problems) {
            problemFromResponse.set(getProblemId(p.contestId, p.index), p);
        }

        var tasks = CodeforcesTask.manager.all();
        for (task in tasks) {
            var p = problemFromResponse.get(getProblemId(task.contestId, task.contestIndex));

            if (p != null && p.tags != null) {
                for (t in p.tags) {
                    var tag = CodeforcesTag.getOrCreateByName(t);
                    var relation = CodeforcesTaskTag.manager.get({ taskId: task.id, tagId: tag.id });
                    if (relation == null) {
                        relation = new CodeforcesTaskTag();
                        relation.task = task;
                        relation.tag = tag;
                        relation.insert();
                    }
                }
            }
        }
    }

    public static function updateUsersResults() {
        var mq: AmqpConnection = new AmqpConnection(getConnectionParams());
        var channel = mq.channel();
        var users: List<User> = User.manager.all();
        var timeNow = Date.now();
        for (user in users) {
            var jobsByUser: Job = Job.manager.search($sessionId == "Update user results : " + user.id).first();
            if (jobsByUser == null ||
                timeNow.getTime() > DateTools.delta(
                    if (jobsByUser != null) jobsByUser.creationDateTime else Date.fromTime(0),
                    43200 * 1000
                ).getTime()
            ) {
                var session = Session.getSessionByUser(user);
                var isOfflineUserShouldUpdate: Bool = DateTools.delta(
                    if (user.lastResultsUpdateDate != null) user.lastResultsUpdateDate else Date.fromTime(0),
                    86400 * 1000
                ).getTime() < timeNow.getTime();
                var isOnlineUserShouldUpdate: Bool = DateTools.delta(
                    if(session != null) session.lastRequestTime else Date.fromTime(0),
                    1800 * 1000
                ).getTime() > timeNow.getTime() &&
                DateTools.delta(
                    if (user.lastResultsUpdateDate != null) user.lastResultsUpdateDate else Date.fromTime(0),
                    300 * 1000
                ).getTime() < timeNow.getTime();
                if (user.lastResultsUpdateDate == null || isOfflineUserShouldUpdate || isOnlineUserShouldUpdate) {
                    publishScholaeJob(channel, ScholaeJob.UpdateUserResults(user.id), "Update user results : " + user.id);
                }
            }
        }
        channel.close();
        mq.close();
    }

    private static function getConnectionParams(): ConnectionParameters {
        var params:ConnectionParameters = new ConnectionParameters();
        params.username = "scholae";
        params.password = "scholae";
        params.vhostpath = "scholae";
        params.serverhost = "127.0.0.1";
        return params;
    }

    private static function publishScholaeJob(channel: Channel, job: ScholaeJob, sessionId: String): Float {
        var jobModel = new Job();
        jobModel.sessionId  = sessionId;
        jobModel.request = job;
        jobModel.progress = 0.0;
        jobModel.creationDateTime = Date.now();
        jobModel.modificationDateTime = jobModel.creationDateTime;
        jobModel.insert();

        channel.publish(Bytes.ofString(Serializer.run({
            id: jobModel.id,
            job: job
        })),"jobs" ,"common");

        return jobModel.id;
    }

    public static function updateCodeforcesData() {
        var mq: AmqpConnection = new AmqpConnection(getConnectionParams());
        var channel = mq.channel();
        trace("start update");
        var job: Job = Job.manager.search($sessionId == "updateCodeforcesData").first();
        if(job == null) {
            trace("send job");
            publishScholaeJob(channel, ScholaeJob.UpdateCodeforcesData(cfg), "updateCodeforcesData");
        }
        channel.close();
        mq.close();
    }
}
