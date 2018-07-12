package ;

import codeforces.Contest;
import haxe.ds.IntMap;
import model.CodeforcesTask;
import codeforces.ProblemStatistics;
import haxe.ds.StringMap;
import codeforces.ProblemsResponse;
import codeforces.Codeforces;
import haxe.EnumTools;
import haxe.EnumTools.EnumValueTools;

enum Action {
    updateCodeforcesTasks;
    updateCodeforcesTasksLevelsAndTypes;
    updateGymTasks;
}

typedef Config = {
    action: Action,
    batchCount: Int
}

class Main {

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

        var cfg: Config = { action: null, batchCount: 100 };

        var args = Sys.args();
        var argHandler = hxargs.Args.generate([
            @doc("Action: updateCodeforcesTasks, updateCodeforcesTasksLevelsAndTypes, updateGymTasks")
            ["-a", "--action"] => function(action:String) cfg.action = EnumTools.createByName(Action, action),

            @doc("Limit number of processing items. Works only for updateGymTasks")
            ["-c", "--count"] => function(count:String) cfg.batchCount = Std.parseInt(count),

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
        }

        sys.db.Manager.cleanup();
        cnx.close();
    }

    public static function updateCodeforcesTasks() {
        updateCodeForcesTasksByResoponse(Codeforces.getAllProblemsResponse());
    }

    private static function updateCodeForcesTasksByResoponse(response: ProblemsResponse) {
        var getProblemStatisticsId = function(s: Dynamic) { return Std.string(s.contestId) + "::" + s.index; };

        var statistics: StringMap<ProblemStatistics> =  new StringMap<ProblemStatistics>();

        for (s in response.problemStatistics) {
            statistics.set(getProblemStatisticsId(s), s);
        }

        for (p in response.problems) {
            if (p.type != "PROGRAMMING") continue;
            var t: CodeforcesTask = CodeforcesTask.getByCodeforcesProblem(p);
            var s = statistics.get(getProblemStatisticsId(p));
            t.solvedCount = if (s != null) s.solvedCount else 0;
            t.update();
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
            var contest = contests.get(t.contestId);

            t.type = contest.type;

            if (contest.difficulty != null) {
                var contestSum: Int = Lambda.fold(tasksByContest.get(t.contestId), function(t, sum) { return sum + t.solvedCount;}, 0);
                var contestMiddle = contestSum / Lambda.count(tasksByContest.get(t.contestId));

                if (t.solvedCount < contestMiddle - contestSum / 6) {
                    t.level = Std.int(Math.max(1, contest.difficulty - 1));
                } else if (t.solvedCount > contestMiddle + contestSum / 6) {
                    t.level = Std.int(Math.min(contest.difficulty + 1, 5));
                } else {
                    t.level = contest.difficulty;
                }

                if (t.level <= 0) {
                    trace(t.level);
                    trace(contest.difficulty);
                    trace(contestSum);
                    trace(contestMiddle);
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
}
