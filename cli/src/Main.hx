package ;

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


enum Action {
    updateCodeforcesTasks;
    updateCodeforcesTasksLevelsAndTypes;
    updateGymTasks;
    updateTags;
    insertTaskId;
}

typedef Config = {
    action: Action,
    batchCount: Int,
    verbose: Bool
}


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
            @doc("Action: updateCodeforcesTasks, updateCodeforcesTasksLevelsAndTypes, updateGymTasks, updateTags")
            ["-a", "--action"] => function(action:String) cfg.action = EnumTools.createByName(Action, action),

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
            case Action.updateCodeforcesTasks: updateCodeforcesTasks();
            case Action.updateCodeforcesTasksLevelsAndTypes: updateCodeforcesTasksLevelsAndTypes();
            case Action.updateGymTasks: updateGymTasks(cfg);
            case Action.updateTags: updateTags();
            case Action.insertTaskId: insertTaskId();
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

    public static function insertTaskId() {
        var isNull:Null<SBigInt> = null;
        var a = Attempt.manager.count($taskId == isNull);
        var i = 1;
        while (i <= a) {
            var attempt = Attempt.manager.select($taskId == isNull);
            var d = Json.parse(attempt.description);
            var contestId = Reflect.field(d,"contestId");
            var index = Reflect.field(d.problem,"index");
            var codeforcesTask = CodeforcesTask.manager.select({contestId: contestId, contestIndex: index});
            attempt.task = codeforcesTask;
            attempt.update();
            i++;
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
}
