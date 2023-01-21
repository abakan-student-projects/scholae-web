package messages;

typedef ExerciseMessage = {
    id: Float,
    trainingId: Float,
    task: TaskMessage,
    ?attempts: Array<AttemptMessage>
}
