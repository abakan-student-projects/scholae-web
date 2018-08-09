package model;

import messages.AssignmentMessage;
import sys.db.Manager;
import sys.db.Types;

@:table("Assignments")
class Assignment extends sys.db.Object {
    public var id: SBigId;
    public var startDateTime: SDateTime;
    public var finishDateTime: SDateTime;
    @:relation(groupId) public var group: Group;
    @:relation(metaTrainingId) public var metaTraining: MetaTraining;
    public var learnerIds: SData<Array<Float>>;
    public var name: SString<512>;

    public function new() {
        super();
    }

    public static var manager = new Manager<Assignment>(Assignment);

    public function toMessage(): AssignmentMessage {
        return {
            id: id,
            startDate: startDateTime,
            finishDate: finishDateTime,
            name: name,
            metaTraining: metaTraining.toMessage(),
            learnerIds: learnerIds,
            groupId: group.id
        };
    }
}
