package messages;

typedef TrainingMessage = {
    id: Float,
    name: String,
    assignmentId: Float,
    userId: Float,
    exercises: Array<ExerciseMessage>
}
