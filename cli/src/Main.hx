package ;

import codeforces_runner.CodeforcesRunner;
import codeforces_runner.Config;
import codeforces_runner.Action;
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

    private static var codeforcesRunner: CodeforcesRunner =
        new CodeforcesRunner({ action: null, batchCount: 100, verbose: false });

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

        var args = Sys.args();
        var argHandler = hxargs.Args.generate([
            @doc("codeforces.Action: updateCodeforcesTasks, updateCodeforcesTasksLevelsAndTypes, updateGymTasks,
            updateTags, updateTaskIdsOnAttempts, updateUsersResults, updateCodeforcesData")
            ["-a", "--action"] => function(action:String) codeforcesRunner.cfg.action = EnumTools.createByName(Action, action),

            @doc("Limit number of processing items. Works only for updateGymTasks")
            ["-c", "--count"] => function(count:String) codeforcesRunner.cfg.batchCount = Std.parseInt(count),

            @doc("Enable the verbose mode")
            ["-v", "--verbose"] => function() codeforcesRunner.cfg.verbose=true,

            _ => function(arg:String) throw "Unknown command: " +arg
        ]);

        argHandler.parse(args);

        if (args.length <= 0) {
            Sys.println("Scholae command line tool");
            Sys.println(argHandler.getDoc());
            Sys.exit(0);
        }

        switch (codeforcesRunner.cfg.action) {
            case Action.updateCodeforcesTasks: updateCodeforcesTasks();//1
            case Action.updateCodeforcesTasksLevelsAndTypes: updateCodeforcesTasksLevelsAndTypes();//3
            case Action.updateGymTasks: updateGymTasks();//2
            case Action.updateTags: updateTags();//0
            case Action.updateTaskIdsOnAttempts: updateTaskIdsOnAttempts();//4
            case Action.updateUsersResults: updateUsersResults();
            case Action.updateCodeforcesData: updateCodeforcesData();
        }

        sys.db.Manager.cleanup();
        cnx.close();
    }

    public static function updateCodeforcesTasks() {
        codeforcesRunner.runUpdateCodeforces(Action.updateCodeforcesTasks);
    }

    public static function updateTaskIdsOnAttempts() {
        codeforcesRunner.runUpdateCodeforces(Action.updateTaskIdsOnAttempts);
    }

    public static function updateCodeforcesTasksLevelsAndTypes() {
        codeforcesRunner.runUpdateCodeforces(Action.updateCodeforcesTasksLevelsAndTypes);
    }

    public static function updateGymTasks() {
        codeforcesRunner.runUpdateCodeforces(Action.updateGymTasks);
    }

    public static function updateTags() {
        trace(codeforcesRunner);
        codeforcesRunner.runUpdateCodeforces(Action.updateTags);
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
            publishScholaeJob(channel, ScholaeJob.UpdateCodeforcesData(codeforcesRunner.cfg), "updateCodeforcesData");
        }
        channel.close();
        mq.close();
    }
}
