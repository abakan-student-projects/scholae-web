package model;

import messages.TagMessage;
import sys.db.Types;
import sys.db.Manager;

@:table("CodeforcesTags")
class CodeforcesTag extends sys.db.Object {
    public var id: SBigId;
    public var name: SString<512>;
    public var russianName: SString<512>;

    public function new() {
        super();
    }

    public static var manager = new Manager<CodeforcesTag>(CodeforcesTag);

    public static function getOrCreateByName(name: String): CodeforcesTag  {
        var tag: CodeforcesTag = manager.select({ name: name });
        var isNew = false;

        if (null == tag) {
            tag = new CodeforcesTag();
            tag.name = name;
            tag.insert();
        }
        return tag;
    }

    public function toMessage(): TagMessage {
        return {
            id: id,
            name: name,
            russianName: russianName
        };
    }
}
