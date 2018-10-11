package messages;

import messages.NeercContestMessage;

typedef NeercTeamMessage = {
    id: Float,
    name: String,
    rank: Int,
    solvedProblemsCount: Int,
    time: Int,
    contest: NeercContestMessage
}
