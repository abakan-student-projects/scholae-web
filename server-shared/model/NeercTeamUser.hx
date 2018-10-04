package model;

import messages.NeercTeamUserMessage;
import sys.db.Manager;
import sys.db.Types;

@:table("NeercTeamUsers")
class NeercTeamUser extends sys.db.Object {
    public var teamId: SBigId;
    public var userId: SBigInt;

    public function new() {
        super();
    }

    public static var manager = new Manager<NeercTeamUser>(NeercTeamUser);

    public function toMessage(): NeercTeamUserMessage {
        return {
            teamId: teamId,
            userId: userId
        };
    }
}
