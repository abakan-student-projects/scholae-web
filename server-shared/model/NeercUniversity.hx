package model;

import messages.NeercUniversityMessage;
import sys.db.Manager;
import sys.db.Types;

@:table("NeercUniversities")
class NeercUniversity extends sys.db.Object {
    public var id: SBigId;
    public var name: SString<512>;

    public function new() {
        super();
    }

    public static var manager = new Manager<NeercUniversity>(NeercUniversity);

    public function toMessage(): NeercUniversityMessage {
        return {
            id: id,
            name: name
        };
    }
}
