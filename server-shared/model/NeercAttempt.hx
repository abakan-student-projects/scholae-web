package model;

import messages.NeercAttemptMessage;
import haxe.Json;
import model.CodeforcesTask;
import model.CodeforcesUser;
import codeforces.Codeforces;
import sys.db.Manager;
import sys.db.Types;

@:table("NeercAttempts")
class NeercAttempt extends sys.db.Object {
    public var id: SBigId;
    public var vendorId: Float;
    @:relation(taskId) public var task : CodeforcesTask;
    @:relation(userId) public var user : CodeforcesUser;
    public var description: SSmallText;
    public var solved: SBool;
    public var datetime: SDateTime;

    public function new() {
        super();
    }

    public static var manager = new Manager<NeercAttempt>(NeercAttempt);

    public static function updateNeercAttemptsForUser(user: CodeforcesUser): Int {
        if (null == user.handle) return -1;

        var submissions = Codeforces.getUserSubmissions(user.handle);

        var lastSubmissionId = user.lastCodeforcesSubmissionId;

        var tasks: Array<CodeforcesTask> = Lambda.array(CodeforcesTask.manager.all());

        // trace(lastSubmissionId);

        for (s in submissions) {
            if (s.id <= user.lastCodeforcesSubmissionId) break;
            lastSubmissionId = Math.max(lastSubmissionId, s.id);
            var task = CodeforcesTask.manager.select($contestId == s.problem.contestId && $contestIndex == s.problem.index);
            var a: NeercAttempt = new NeercAttempt();
            a.vendorId = s.id;
            if (task != null)
                a.task = task;
            a.user = user;
            a.description = Json.stringify(s);
            a.datetime = Date.fromTime(s.creationTimeSeconds * 1000.0);
            a.solved = s.testset != "PRETESTS" && s.testset != "SAMPLES" && s.verdict == "OK";
            a.insert();
        }

        user.lock();
        user.lastCodeforcesSubmissionId = lastSubmissionId;
        user.update();

        return submissions.length;
    }

    public function toMessage(): NeercAttemptMessage {
        return {
            id: id,
            task: task.toMessage(user),
            // learner: user.toLearnerMessage(),
            description: description,
            solved: solved,
            datetime: datetime,
            // trainingId: null,
            // assignmentId: null,
            // groupId: null
        };
    }

    /*public static function getLastNeercAttemptsForExercises(exercises: Iterable<Exercise>, length: Int): List<NeercAttempt> {
        var tasks = Lambda.map(exercises, function(e) { return e.task.id; });
        var learners = Lambda.map(exercises, function(e) { return e.training.user.id; });
        return NeercAttempt.manager.search(($taskId in tasks) && ($userId in learners), { orderBy: -datetime, limit: length});
    }*/


    
}
