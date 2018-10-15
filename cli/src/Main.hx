package ;

import sys.db.Types.SBigInt;
import model.Attempt;
import model.CodeforcesTaskTag;
import model.CodeforcesTag;
import model.CodeforcesUser;
import model.NeercUser;
import model.NeercTeam;
import model.NeercTeamUser;
import model.NeercContest;
import model.NeercAttempt;
import codeforces.Problem;
import codeforces.Codeforces;
import codeforces.Contest;
import codeforces.Submission;
import haxe.ds.IntMap;
import model.CodeforcesTask;
import codeforces.ProblemStatistics;
import haxe.ds.StringMap;
import codeforces.ProblemsResponse;
import codeforces.Codeforces;
import parser.Neerc;
import parser.CodeforcesUsers;
import haxe.EnumTools;
import haxe.EnumTools.EnumValueTools;
import haxe.Json;


enum Action {
    updateCodeforcesTasks;
    updateCodeforcesTasksLevelsAndTypes;
    updateGymTasks;
    updateTags;
    updateTaskIdsOnAttempts;
    updateNeercData;
    updateCodeforcesUsersHandles;
    updateCodeforcesUsersNames;
    updateNeercUsersRelationWithCodeforces;
    updateAttemptsForNeercUsers;
    updateLearnerRating;
    updateNeercAll;
    saveCorrelationData;
    updateNeercSolvedProblems;
    updateCorrelation;
}

typedef Config = {
    action: Action,
    batchCount: Int,
    verbose: Bool,
    solvedProblemsYear: Int,
    correlationYear: Int
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

        cfg = { action: null, batchCount: 100, verbose: false, solvedProblemsYear: 2017, correlationYear: 2017 };

        var args = Sys.args();
        var argHandler = hxargs.Args.generate([
            @doc("Action: updateCodeforcesTasks, updateCodeforcesTasksLevelsAndTypes, updateGymTasks, updateTags, updateTaskIdsOnAttempts, updateNeercData, updateCodeforcesUsersHandles, updateCodeforcesUsersNames, updateNeercUsersRelationWithCodeforces")
            ["-a", "--action"] => function(action:String) cfg.action = EnumTools.createByName(Action, action),

            @doc("Limit number of processing items. Works only for updateGymTasks")
            ["-c", "--count"] => function(count:String) cfg.batchCount = Std.parseInt(count),

            @doc("Enable the verbose mode")
            ["-v", "--verbose"] => function() cfg.verbose=true,

            @doc("Output Neerc users rating on Codeforces")
            ["-s", "--solved-problems"] => function(solvedProblemsYear:String) cfg.solvedProblemsYear = Std.parseInt(solvedProblemsYear),

            @doc("Year for correlation (default: 2017)")
            ["-k", "--correlation"] => function(correlationYear:String) cfg.correlationYear = Std.parseInt(correlationYear),

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
            case Action.updateTaskIdsOnAttempts: updateTaskIdsOnAttempts();
            case Action.updateNeercData: updateNeercData();
            case Action.updateCodeforcesUsersHandles: CodeforcesUsers.ParseUsersFromRussia();
            case Action.updateCodeforcesUsersNames: CodeforcesUsers.updateCodeforcesUsersNames();
            case Action.updateNeercUsersRelationWithCodeforces: updateNeercUsersRelationWithCodeforces();
            case Action.updateAttemptsForNeercUsers: updateAttemptsForNeercUsers();
            case Action.updateLearnerRating: updateLearnerRating();
            case Action.updateNeercAll: updateNeercAll();
            case Action.saveCorrelationData: saveCorrelationData(cfg.correlationYear);
            case Action.updateNeercSolvedProblems: updateNeercSolvedProblems(cfg.solvedProblemsYear);
            case Action.updateCorrelation: updateCorrelation(cfg.correlationYear);
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

    public static function updateNeercData() {
        var firstYear = 2015;
        var lastYear = 2017;

        for (year in firstYear...lastYear + 1) {
            Neerc.startParsing("http://neerc.ifmo.ru/archive/" + (firstYear + (lastYear - year)) + "/standings.html", (firstYear + (lastYear - year)));
        }
    }

    public static function updateNeercUsersRelationWithCodeforces() {
        var codeforcesUsersList = Lambda.array(CodeforcesUser.manager.all());
        var neercUsersList = Lambda.array(NeercUser.manager.all());
        var codeforcesUsers: Array<String> = Lambda.array(Lambda.map(codeforcesUsersList, function(user) {
            return user.lastName;
        }));
        var neercUsers: Array<String> = Lambda.array(Lambda.map(neercUsersList, function(user) {
            return user.lastName;
        }));
        var indexes: Array<Float> = [];
        var updated = 0;

        for (i in 0...neercUsers.length) {
            if (neercUsers[i] != "null") {
                var index = codeforcesUsers.indexOf(neercUsers[i]);
                var users: Array<CodeforcesUser> = Lambda.array(CodeforcesUser.manager.search($lastName == neercUsers[i]));

                if (users != null && users.length == 1) {
                    var user: CodeforcesUser = users[0];

                    if (indexes.indexOf(user.id) == -1) {
                        var neerc = NeercUser.manager.select({id: neercUsersList[i].id});
                        neerc.codeforcesUser = user;
                        neerc.update();

                        indexes.push(user.id);
                        updated++;
                    }
                }
            }
        }
        trace("Updated " + updated + " records");
    }

    public static function updateUserSolvedProblemsByHandle(handle: String): Int {
        var submissions: Array<Submission> = Codeforces.getUserSubmissions(handle);
        var problems = 0;

        if (submissions.length > 0) {
            for (i in 0...submissions.length) {
                if (submissions[i].verdict == "OK") {
                    problems++;
                }
            }

            var user = CodeforcesUser.manager.select($handle == handle, true);

            if (user != null) {
                user.solvedProblems = problems;
                user.update();
            }
        }

        Sys.sleep(0.3);

        return problems;
    }

    public static function updateNeercSolvedProblems(year: Int) {
        functionWithTeamMembersByYear(year, function(team: NeercTeam, members: Array<NeercTeamUser>) {
            trace(team.rank + ". " + team.name + ":");

            for (j in 0...members.length) {
                if (members[j].user.codeforcesUser != null && members[j].user.codeforcesUser.handle != null) {
                    var handle = members[j].user.codeforcesUser.handle;
                    trace(handle + ": " + updateUserSolvedProblemsByHandle(handle));
                }
            }
        });
    }

    public static function getNeercPlaceByUserHandle(handle: String): Int {
        var user = CodeforcesUser.manager.select($handle == handle, true);

        if (user != null) {
            var neercUser = NeercUser.manager.select($codeforcesUser == user, true);

            if (neercUser != null) {
                var teams = NeercTeamUser.manager.select($user == neercUser);

                if (teams != null) {
                    return teams.team.rank;
                }
            }
        }

        return 0;
    }

    public static function updateCorrelation(year: Int) {
        var data: Array<Array<Int>> = [];

        var contest: NeercContest = NeercContest.manager.select($year == year, true);

        if (contest != null) {
            var teams: Array<NeercTeam> = Lambda.array(NeercTeam.manager.search($contestId == contest.id, false));

            for (i in 0...teams.length) {
                var members: Array<NeercTeamUser> = Lambda.array(NeercTeamUser.manager.search($team == teams[i], true));
                var x: Float = 0;
                var y: Float = 0;

                for (j in 0...members.length) {
                    if (members[j].user.codeforcesUser != null && members[j].user.codeforcesUser.handle != null && members[j].user.codeforcesUser.learnerRating > 0) {
                        x += (members[j].user.codeforcesUser.learnerRating > x) ? members[j].user.codeforcesUser.learnerRating : x;
                        // y += (members[j].user.codeforcesUser.solvedProblems > y) ? members[j].user.codeforcesUser.solvedProblems : y;
                    }   
                }
                y = teams[i].rank;

                data.push([Std.parseInt(x + ""), Std.parseInt(y + "")]);
            }

            trace(getPearsonCorrelation(data));
        } else {
            trace("Contest not found");
        }
    }

    public static function saveCorrelationData(year: Int) {
        var contest: NeercContest = NeercContest.manager.select($year == year, true);
        var tags: List<CodeforcesTag> = CodeforcesTag.manager.all();

        if (contest != null) {
            var teams: Array<NeercTeam> = Lambda.array(NeercTeam.manager.search($contestId == contest.id, false));

            Sys.print('neerc team rank; meanTeamRatingOnCodeforce; maxTeamRatingOnCodeforce; ' +
            'meanTeamSolvedProblemsOnCodeforce; maxTeamSolvedProblemsOnCodeforce; ' +
            'meanLearnerRating; maxLearnerRating; ' +
            'meanLearnerRating1; maxLearnerRating1; '
            );

            for (t in tags) {
                Sys.print(t.name + "; ");
            }

            Sys.println("");

            for (i in 0...teams.length) {
                var teamSolvedByTags: StringMap<Float> = new StringMap<Float>();

                var members: Array<NeercTeamUser> = Lambda.array(NeercTeamUser.manager.search($team == teams[i], true));
                var meanTeamRatingOnCodeforce = 0.0;
                var maxTeamRatingOnCodeforce = 0.0;
                var meanTeamSolvedProblemsOnCodeforce = 0.0;
                var maxTeamSolvedProblemsOnCodeforce = 0.0;
                var meanLearnerRating = 0.0;
                var maxLearnerRating = 0.0;
                var meanLearnerRating1 = 0.0;
                var maxLearnerRating1 = 0.0;
//                trace(teams[i]);

                for (j in 0...members.length) {

//                    trace(members[j]);
                    if (members[j].user.codeforcesUser != null && members[j].user.codeforcesUser.solvedProblems > 20) {
                        meanTeamSolvedProblemsOnCodeforce += members[j].user.codeforcesUser.solvedProblems/3;
                        maxTeamSolvedProblemsOnCodeforce = Math.max(members[j].user.codeforcesUser.solvedProblems, maxTeamSolvedProblemsOnCodeforce);

                        meanTeamRatingOnCodeforce += members[j].user.codeforcesUser.rating/3;
                        maxTeamRatingOnCodeforce = Math.max(members[j].user.codeforcesUser.rating, maxTeamRatingOnCodeforce);

                        meanLearnerRating += members[j].user.codeforcesUser.learnerRating/3;
                        maxLearnerRating = Math.max(members[j].user.codeforcesUser.learnerRating, maxLearnerRating);

                        var learnerRating1 = 0.0;
                        var solvedByTags: StringMap<Float> = new StringMap<Float>();

                        var successfulAttempts: List<NeercAttempt> = NeercAttempt.manager.search($userId == members[j].user.codeforcesUser.id && $solved == true);
                        if (successfulAttempts != null) {


                            for (a in successfulAttempts) {
                                if (a.task == null) continue;
                                var tags = CodeforcesTaskTag.manager.search($taskId == a.task.id);
                                for (tt in tags) {
                                    var id = Std.string(tt.tag.id);
                                    var v = if (solvedByTags.exists(id)) solvedByTags.get(id) else 0.0;
                                    solvedByTags.set(id, v + a.task.level);
                                }
                            }


                            for (s in solvedByTags) {
                                learnerRating1 += Math.log(s);
                            }

                            for (t in tags) {
                                var id = Std.string(t.id);
                                var teamV = if (teamSolvedByTags.exists(id)) teamSolvedByTags.get(id) else 0.0;
                                var memberV = if (solvedByTags.exists(id)) solvedByTags.get(id) else 0.0;
                                teamSolvedByTags.set(id, Math.max(teamV, memberV));
                            }
                        }

                        meanLearnerRating1 += learnerRating1/3;
                        maxLearnerRating1 = Math.max(learnerRating1, maxLearnerRating1);
                    }


                }

                if (maxTeamSolvedProblemsOnCodeforce > 20) {
                    Sys.print('${teams[i].rank}; $meanTeamRatingOnCodeforce; $maxTeamRatingOnCodeforce; ' +
                                '$meanTeamSolvedProblemsOnCodeforce; $maxTeamSolvedProblemsOnCodeforce; ' +
                                '$meanLearnerRating; $maxLearnerRating; ' +
                                '$meanLearnerRating1; $maxLearnerRating1; '
                    );

                    for (t in tags) {
                        var v = teamSolvedByTags.get(Std.string(t.id));
                        Sys.print((if (v != 0) Math.log(v) else v) + "; ");
                    }
                    Sys.println("");
                }
            }

        } else {
            trace("Contest not found");
        }
    }

    public static function getUsersByContestId(id: Float): Array<NeercUser> {
        var users: Array<NeercUser> = [];
        var teams: Array<NeercTeam> = Lambda.array(NeercTeam.manager.search($contestId == id, false));

        if (teams != null) {
            for (i in 0...teams.length) {
                var members: Array<NeercTeamUser> = Lambda.array(NeercTeamUser.manager.search($team == teams[i], true));

                for (j in 0...members.length) {
                    if (members[j].user != null) {
                        users.push(members[j].user);
                    }
                }
            }
        }

        return users;
    }

    public static function getPearsonCorrelation(data: Array<Array<Int>>): Float {
        var uX: Float = 0;
        var uY: Float = 0;
        var sum: Float = 0;
        var sumXSqr: Float = 0;
        var sumYSqr: Float = 0;

        for (i in 0...data.length) {
            uX += data[i][0];
            uY += data[i][1];
        }

        uX /= data.length;
        uY /= data.length;

        for (i in 0...data.length) {
            sum += (data[i][0] - uX) * (data[i][1] - uY);
            sumXSqr += Math.pow(data[i][0] - uX, 2);
            sumYSqr += Math.pow(data[i][1] - uY, 2);
        }

        return sum / Math.sqrt(sumXSqr * sumYSqr);
    }

    public static function updateAttemptsForNeercUsers() {
        var users = CodeforcesUser.manager.search($solvedProblems > 0);

        for (user in users) {
            var attempts = NeercAttempt.updateNeercAttemptsForUser(user);
            if (attempts >= 0)
                trace("Added " + attempts + " attempts for " + user.handle);
        }
    }

    public static function updateLearnerRating() {
        var contests = NeercContest.manager.all();

        for (contest in contests) {
            functionWithTeamMembersByYear(contest.year, function(team: NeercTeam, members: Array<NeercTeamUser>) {
                for (i in 0...members.length) {
                    if (members[i].user.codeforcesUser != null) {
                        members[i].user.codeforcesUser.lock();
                        members[i].user.codeforcesUser.learnerRating = CodeforcesUser.calculateLearnerRating(members[i].user.codeforcesUser);
                        members[i].user.codeforcesUser.update();

                        trace(members[i].user.codeforcesUser.handle + ": " + members[i].user.codeforcesUser.learnerRating);
                    }
                }
            });
        }
    }

   public static function functionWithTeamMembersByYear(year: Int, f: haxe.Constraints.Function) {
        var data: Array<Array<Int>> = [];
        var contest: NeercContest = NeercContest.manager.select($year == year);

        if (contest != null) {
            var teams: Array<NeercTeam> = Lambda.array(NeercTeam.manager.search($contestId == contest.id, false));

            for (i in 0...teams.length) {
                var members: Array<NeercTeamUser> = Lambda.array(NeercTeamUser.manager.search($team == teams[i], false));
                
                if (members != null) {
                    f(teams[i], members);
                }
            }
        }
    }

    public static function updateNeercAll() {
        updateNeercData();
        CodeforcesUsers.ParseUsersFromRussia();
        CodeforcesUsers.updateCodeforcesUsersNames();
        updateNeercUsersRelationWithCodeforces();

        var contests = NeercContest.manager.all();

        for (i in contests) {
            updateNeercSolvedProblems(i.year);
        }

        updateAttemptsForNeercUsers();
        updateLearnerRating();
    }
}
