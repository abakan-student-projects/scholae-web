package model;

import messages.AttemptMessage;
import messages.ExerciseMessage;
import sys.db.Manager;
import sys.db.Types;

@:table("Exercises")
class Exercise extends sys.db.Object {
    public var id: SBigId;
    @:relation(taskId) public var task : CodeforcesTask;
    @:relation(trainingId) public var training : Training;
    public var deleted: SBool;
    
    public function new() {
        super();
    }

    public static var manager = new Manager<Exercise>(Exercise);

    public static function getExercisesByTraining(trainingId: Float): List<Exercise> {
        return manager.search($trainingId == trainingId && $deleted != true);
    }

    public function toMessage(): ExerciseMessage {
        var attempts: Array<AttemptMessage> = Lambda.array(
            Lambda.map(
                Attempt.manager.search(
                    $userId == training.user.id &&
                    $taskId == task.id),
                function(t){ return t.toMessage();}
            ));
        return {
            id: id,
            task: task.toMessage(training.user),
            trainingId: training.id,
            attempts: if(attempts.length != 0) attempts else null
        };
    }

    public static function getAllExercisesForTeacher(teacher: User): List<Exercise> {
        var groups = Lambda.map(Group.manager.search($teacherId == teacher.id && $deleted != true), function(g) { return g.id; });
        var assignments = Lambda.map(Assignment.manager.search(($groupId in groups) && $deleted != true), function(a) { return a.id; });
        var trainings = Lambda.map(Training.manager.search(($assignmentId in assignments) && $deleted != true), function(t) { return t.id; });
        return Exercise.manager.search(($trainingId in trainings) && $deleted != true);
    }
}
