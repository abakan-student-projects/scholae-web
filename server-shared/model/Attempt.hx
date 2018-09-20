package model;

import messages.AttemptMessage;
import haxe.Json;
import model.CodeforcesTask;
import codeforces.Codeforces;
import sys.db.Manager;
import sys.db.Types;

@:table("Attempts")
class Attempt extends sys.db.Object {
    public var id: SBigId;
    public var vendorId: Float;
    @:relation(taskId) public var task : CodeforcesTask;
    @:relation(userId) public var user : User;
    public var description: SSmallText;
    public var solved: SBool;
    public var datetime: SDateTime;

    public function new() {
        super();
    }

    public static var manager = new Manager<Attempt>(Attempt);

    public static function updateAttemptsForUser(user: User) {
        if (null == user.codeforcesHandle) return;

        var submissions = Codeforces.getUserSubmissions(user.codeforcesHandle);

        var lastSubmissionId = user.lastCodeforcesSubmissionId;

        trace(lastSubmissionId);

        for (s in submissions) {
            if (s.id <= user.lastCodeforcesSubmissionId) break;
            lastSubmissionId = Math.max(lastSubmissionId, s.id);

            var a: Attempt = new Attempt();
            a.vendorId = s.id;
            a.task = CodeforcesTask.manager.select($contestId == s.problem.contestId && $contestIndex == s.problem.index);
            a.user = user;
            a.description = Json.stringify(s);
            a.datetime = Date.fromTime(s.creationTimeSeconds * 1000.0);
            a.solved = s.testset != "PRETESTS" && s.testset != "SAMPLES" && s.verdict == "OK";
            a.insert();
        }

        user.lock();
        user.lastCodeforcesSubmissionId = lastSubmissionId;
        user.update();
    }

    public function toMessage(): AttemptMessage {
        return {
            id: id,
            task: task.toMessage(user),
            learner: user.toLearnerMessage(),
            description: description,
            solved: solved,
            datetime: datetime,
            trainingId: null,
            assignmentId: null,
            groupId: null
        };
    }

    public static function getLastAttemptsForExercises(exercises: Iterable<Exercise>, length: Int): List<Attempt> {
        var tasks = Lambda.map(exercises, function(e) { return e.task.id; });
        var learners = Lambda.map(exercises, function(e) { return e.training.user.id; });
        return Attempt.manager.search(($taskId in tasks) && ($userId in learners), { orderBy: -datetime, limit: length});
    }


    
}
