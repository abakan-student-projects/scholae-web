package model;

import messages.MetaTrainingMessage;
import sys.db.Manager;
import sys.db.Types;

@:table("MetaTrainings")
class MetaTraining extends sys.db.Object {
    public var id: SBigId;
    public var minLevel: SInt;
    public var maxLevel: SInt;
    public var length: SInt;
    public var tagIds: SData<Array<Float>>;
    public var taskIds: SData<Array<Float>>;

    public function new() {
        super();
    }

    public static var manager = new Manager<MetaTraining>(MetaTraining);

    public function toMessage(): MetaTrainingMessage {
        return {
            id: id,
            minLevel: minLevel,
            maxLevel: maxLevel,
            tagIds: tagIds,
            taskIds: taskIds,
            length: length
        };
    }
}
