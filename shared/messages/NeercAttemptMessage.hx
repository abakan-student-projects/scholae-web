package messages;

typedef NeercAttemptMessage = {
    id: Float,
    task: TaskMessage,
    description: String,
    solved: Bool,
    datetime: Date,
}
