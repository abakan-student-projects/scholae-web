package messages;

typedef AttemptMessage = {
    id: Float,
    task: TaskMessage,
    learner: LearnerMessage,
    description: String,
    solved: Bool,
    datetime: Date,
    trainingId: Null<Float>,
    assignmentId: Null<Float>,
    groupId: Null<Float>
}
