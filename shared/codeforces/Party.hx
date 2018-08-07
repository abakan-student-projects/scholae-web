package codeforces;

typedef Party = {
    ?contestId: Int,
    members: Array<Member>,
    participanType: String,
    ?teamId: Int,
    teamName: String,
    ghost: Bool,
    ?room: Int,
    startTimeSeconds: Float
}
