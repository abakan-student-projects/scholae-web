package model;

import messages.NeercTeamUserMessage;
import sys.db.Manager;
import sys.db.Types;

@:table("NeercTeamUsers")
@:id(teamId, userId)
class NeercTeamUser extends sys.db.Object {
    @:relation(teamId) public var team : model.NeercTeam;
    @:relation(userId) public var user : model.NeercUser;

    public function new() {
        super();
    }

    public static var manager = new Manager<NeercTeamUser>(NeercTeamUser);

    public function toMessage(): NeercTeamUserMessage {
        return {
            team: team.toMessage(),
            user: user.toMessage()
        };
    }
}
