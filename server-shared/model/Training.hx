package model;

import utils.StringUtils;
import messages.TrainingMessage;
import sys.db.Manager;
import sys.db.Types;

@:table("Trainings")
class Training extends sys.db.Object {
    public var id: SBigId;
    public var name: SString<512>;
    @:relation(userId) public var user : User;
    @:relation(assignmentId) public var assignment : Assignment;
    public var deleted: SBool;

    public function new() {
        super();
    }

    public static var manager = new Manager<Training>(Training);

    public function toMessage(includeAssignment: Bool = false): TrainingMessage {
        return {
            id: id,
            name: if (StringUtils.isStringNullOrEmpty(name)) assignment.name else name,
            assignmentId: assignment.id,
            assignment: if (includeAssignment) assignment.toMessage() else null,
            userId: user.id,
            exercises: Lambda.array(Lambda.map(Exercise.getExercisesByTraining(id), function(e) { return e.toMessage(); }))
        };
    }

    public static function getTrainingsByGroup(groupId: Float): Array<Training> {
        var assignments: List<Assignment> = Assignment.manager.search($groupId == groupId && $deleted != true);
        var trainings: Array<Training> = [];

        for (a in assignments) {
            trainings = trainings.concat(Lambda.array(Training.manager.search($assignmentId == a.id && $deleted != true)));
        }

        return trainings;
    }
    
}
