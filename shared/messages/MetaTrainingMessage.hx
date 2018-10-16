package messages;

typedef MetaTrainingMessage = {
    id: Float,
    minLevel: Int,
    maxLevel: Int,
    tagIds: Array<Float>,

    taskIds: Array<Float>,
    length: Int
}
