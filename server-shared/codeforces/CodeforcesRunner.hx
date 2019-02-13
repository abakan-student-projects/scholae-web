package codeforces;

import codeforces.Contest;
import codeforces.ProblemsResponse;
import codeforces.ProblemStatistics;
import codeforces.Problem;
import codeforces.Codeforces;
import codeforces.RunnerAction;
import haxe.Json;
import model.Attempt;
import model.CodeforcesTaskTag;
import model.CodeforcesTag;
import model.CodeforcesTask;
import haxe.ds.StringMap;
import haxe.ds.IntMap;
import sys.db.Types.SBigInt;

class CodeforcesRunner {
    public var config: RunnerConfig;

    public function new(config: RunnerConfig) {
        this.config = config;
    }

    public function runUpdateCodeforces(action: RunnerAction) {
        switch (config.action) {
            case RunnerAction.updateCodeforcesTasks: updateCodeforcesTasks();//1
            case RunnerAction.updateCodeforcesTasksLevelsAndTypes: updateCodeforcesTasksLevelsAndTypes(config);//3
            case RunnerAction.updateGymTasks: updateGymTasks(config);//2
            case RunnerAction.updateTags: updateTags();//0
            case RunnerAction.updateTaskIdsOnAttempts: updateTaskIdsOnAttempts();//4
            default: null;
        }
    }

    public function runAll() {
        Sys.sleep(0.4);
        trace("Start update codeforces tags");
        updateTags();
        Sys.sleep(0.4);
        trace("Start update codeforces tasks");
        updateCodeforcesTasks();
        Sys.sleep(0.4);
        trace("Start update gym tasks");
        updateGymTasks(config);
        Sys.sleep(0.4);
        trace("Start update codeforces tasks levels and types");
        updateCodeforcesTasksLevelsAndTypes(config);
        Sys.sleep(0.4);
        trace("Start update task ids on attempts");
        updateTaskIdsOnAttempts();
    }

    private function updateTags() {
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

    private inline function getProblemId(contestId: Int, index: String): String {
        return Std.string(contestId) + "::" + index;
    }

    private function updateCodeforcesTasks() {
        updateCodeforcesTasksByResponse(Codeforces.getAllProblemsResponse());
    }

    private function updateGymTasks(config: RunnerConfig) {
        var processed = 0;
        for (c in Codeforces.getGymContests()) {
            if (!CodeforcesTask.doTasksExistForContest(c.id)) {
                updateCodeforcesTasksByResponse(Codeforces.getGymProblemsByContest(c));
                processed += 1;
                if (processed >= config.batchCount) {
                    break;
                }
            }
        }
    }

    private function updateCodeforcesTasksByResponse(response: ProblemsResponse) {
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

    private function updateCodeforcesTasksLevelsAndTypes(config: RunnerConfig) {
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
            if (config.verbose) neko.Lib.println("Task: " + t.toMessage());

            var contest = contests.get(t.contestId);

            if (contest == null) {
                t.lock();
                t.active = false;
                t.update();
                continue;
            }

            if (config.verbose) neko.Lib.println("Task contest: " + contest);

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

    private function updateTaskIdsOnAttempts() {
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
