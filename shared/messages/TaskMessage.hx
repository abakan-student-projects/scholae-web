package messages;

typedef TaskMessage = {
    id: Float,
    name: String,
    level: Int,
    tagIds: Array<Float>,
    isGymTask: Bool,
    codeforcesContestId: Int,
    codeforcesIndex: String,
    isSolved: Bool
}
