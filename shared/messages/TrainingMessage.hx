package messages;

typedef TrainingMessage = {
    id: Float,
    name: String,
    assignmentId: Float,
    assignment: AssignmentMessage,
    userId: Float,
    exercises: Array<ExerciseMessage>
}
