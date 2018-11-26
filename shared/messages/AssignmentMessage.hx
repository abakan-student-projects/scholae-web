package messages;

typedef AssignmentMessage = {
    id: Float,
    startDate: Date,
    finishDate: Date,
    name: String,
    metaTraining: MetaTrainingMessage,
    groupId: Float,
    learnerIds: Array<Float>
}
