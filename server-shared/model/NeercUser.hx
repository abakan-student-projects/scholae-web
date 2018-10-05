package model;

import messages.NeercUserMessage;
import sys.db.Manager;
import sys.db.Types;

@:table("NeercUsers")
class NeercUser extends sys.db.Object {
    public var id: SBigId;
    public var lastName: SString<512>;
    public var codeforcesUsersId: SBigInt;
    public var universityId: SBigInt;

    public function new() {
        super();
    }

    public static var manager = new Manager<NeercUser>(NeercUser);

    public function toMessage(): NeercUserMessage {
        return {
            id: id,
            lastName: lastName,
            codeforcesUsersId: codeforcesUsersId,
            universityId: universityId
        };
    }
}
