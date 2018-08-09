package messages;

typedef AttemptMessage = {
    id: Float,
    task: TaskMessage,
    learner: LearnerMessage,
    description: String,
    solved: Bool,
    datetime: Date,
    trainingId: Float,
    assignmentId: Float,
    groupId: Float
}
