package model;

import messages.NeercTeamMessage;
import model.NeercContest;
import sys.db.Manager;
import sys.db.Types;

@:table("NeercTeams")
class NeercTeam extends sys.db.Object {
    public var id: SBigId;
    public var name: SString<512>;
    public var rank: SInt;
    public var contestId: SBigInt;
    public var solvedProblemsCount: SInt;
    public var time: SInt;
    @:relation(contestId) public var contest : NeercContest;

    public function new() {
        super();
    }

    public static var manager = new Manager<NeercTeam>(NeercTeam);

    public function toMessage(): NeercTeamMessage {
        return {
            id: id,
            name: name,
            rank: rank,
            contestId: contestId,
            solvedProblemsCount: solvedProblemsCount,
            time: time,
            contest: contest.toMessage()
        };
    }
}
