package model;

import messages.ExerciseMessage;
import sys.db.Manager;
import sys.db.Types;

@:table("Exercises")
class Exercise extends sys.db.Object {
    public var id: SBigId;
    @:relation(taskId) public var task : CodeforcesTask;
    @:relation(trainingId) public var training : Training;
    
    public function new() {
        super();
    }

    public static var manager = new Manager<Exercise>(Exercise);

    public static function getExercisesByTraining(trainingId: Float): List<Exercise> {
        return manager.search($trainingId == trainingId);
    }

    public function toMessage(): ExerciseMessage {
        return {
            id: id,
            task: task.toMessage(),
            trainingId: training.id
        };
    }
}
