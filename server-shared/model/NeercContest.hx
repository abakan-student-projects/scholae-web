package model;

import messages.NeercContestMessage;
import sys.db.Connection;
import sys.db.Manager;
import sys.db.Types;

@:table("NeercContests")
class NeercContest extends sys.db.Object {
    public var id: SBigId;
    public var name: SString<512>;
    public var year: SInt;

    public function new() {
        super();
    }

    public static var manager = new Manager<NeercContest>(NeercContest);

    public function toMessage(): NeercContestMessage {
        return {
            id: id,
            name: name,
            year: year
        };
    }
}
