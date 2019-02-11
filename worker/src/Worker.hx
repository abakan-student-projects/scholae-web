package ;

import codeforces.Contest;
import model.Config;
import model.Action;
import codeforces.ProblemsResponse;
import codeforces.ProblemStatistics;
import model.CodeforcesTaskTag;
import model.CodeforcesTag;
import model.CodeforcesTask;
import codeforces.Problem;
import codeforces.Codeforces;
import model.User;
import messages.MessagesHelper;
import model.Training;
import messages.ResponseStatus;
import haxe.EnumTools.EnumValueTools;
import model.Job;
import jobs.JobMessage;
import model.Attempt;
import model.GroupLearner;
import haxe.Unserializer;
import jobs.ScholaeJob;
import org.amqp.fast.FastImport.Delivery;
import org.amqp.fast.FastImport.Channel;
import org.amqp.ConnectionParameters;
import org.amqp.fast.neko.AmqpConnection;
import haxe.ds.StringMap;
import haxe.ds.IntMap;
import haxe.Json;
import sys.db.Types.SBigInt;

class Worker {

    private var mq: AmqpConnection;
    private var channel: Channel;

    public function new() {
        trace("Started");
        mq = new AmqpConnection(getConnectionParams());
        //trace("Connection is up " + mq);
        channel = mq.channel();
        //trace("Channel:" + channel);
        //channel.bind("jobs_common", "jobs", null);
        channel.consume("jobs_common", onConsume, false);
        trace("On consume is setup");
    }

    public static function getConnectionParams(): ConnectionParameters {
        var params:ConnectionParameters = new ConnectionParameters();
        params.username = "scholae";
        params.password = "scholae";
        params.vhostpath = "scholae";
        params.serverhost = "127.0.0.1";
        return params;
    }

    public function run() {
        trace("The loop is running...");
        while(true) {
            mq.deliver(false);
            Sys.sleep(0.0001);
        }
    }

    public function onConsume(delivery: Delivery) {

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

        var c = delivery.body.readAll().toString();

        trace(c);

        var msg: JobMessage = Unserializer.run(c);

        if (msg != null) {
            trace(EnumValueTools.getName(msg.job));
            switch(msg.job) {
                case UpdateUserResults(userId): {
                    var user: User = User.manager.get(userId);
                    Sys.sleep(0.4);
                    Attempt.updateAttemptsForUser(user);
                    var job: Job = Job.manager.get(msg.id);
                    if (null != job) {
                        job.delete();
                    };
                };

                case RefreshResultsForUser(userId): {
                    var user: User = User.manager.get(userId);
                    Sys.sleep(0.4);
                    Attempt.updateAttemptsForUser(user);
                    var job: Job = Job.manager.get(msg.id);
                    if (null != job) {
                        job.response = MessagesHelper.successResponse(
                            Lambda.array(
                                Lambda.map(
                                    Training.manager.search($userId == userId && $deleted != true),
                                    function(t) { return t.toMessage(true); })));
                        job.modificationDateTime = Date.now();
                        job.update();
                    };
                };

                case RefreshResultsForGroup(groupId): {
                    for (gl in GroupLearner.manager.search($groupId == groupId)) {
                        Sys.sleep(0.4);
                        Attempt.updateAttemptsForUser(gl.learner);
                    }
                    var job: Job = Job.manager.get(msg.id);
                    if (null != job) {
                        job.response = MessagesHelper.successResponse(
                            Lambda.array(
                                Lambda.map(
                                    Training.getTrainingsByGroup(groupId),
                                    function(t) { return t.toMessage(); })));
                        job.modificationDateTime = Date.now();
                        job.update();
                    };
                };

                case UpdateCodeforcesData(cfg): {
                    Sys.sleep(0.4);
                    trace("Start update codeforces tags");
                    updateCodeforcesTags();
                    Sys.sleep(0.4);
                    trace("Start update codeforces tasks");
                    updateCodeforcesTasks();
                    Sys.sleep(0.4);
                    trace("Start update gym tasks");
                    updateGymTasks(cfg);
                    Sys.sleep(0.4);
                    trace("Start update codeforces tasks levels and types");
                    updateCodeforcesTasksLevelsAndTypes(cfg);
                    Sys.sleep(0.4);
                    trace("Start update task ids on attempts");
                    updateTaskIdsOnAttempts();
                    Sys.sleep(0.4);
                    var job: Job = Job.manager.get(msg.id);
                    if (null != job) {
                        job.delete();
                    };
                };
            }
        }

        sys.db.Manager.cleanup();
        cnx.close();

        Sys.stdout().flush();
        Sys.stderr().flush();

        channel.ack(delivery);
    }

    private function updateCodeforcesTags() {
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

    private static inline function getProblemId(contestId: Int, index: String): String {
        return Std.string(contestId) + "::" + index;
    }

    private static function updateCodeforcesTasks() {
        updateCodeforcesTasksByResponse(Codeforces.getAllProblemsResponse());
    }


    public static function updateGymTasks(cfg: Config) {
        var processed = 0;
        for (c in Codeforces.getGymContests()) {
            if (!CodeforcesTask.doTasksExistForContest(c.id)) {
                updateCodeforcesTasksByResponse(Codeforces.getGymProblemsByContest(c));
                processed += 1;
                if (processed >= cfg.batchCount) {
                    break;
                }
            }
        }
    }

    public static function updateCodeforcesTasksByResponse(response: ProblemsResponse) {
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

    public static function updateCodeforcesTasksLevelsAndTypes(cfg: Config) {
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
}
