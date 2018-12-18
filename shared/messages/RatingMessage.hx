package messages;

typedef RatingCategory = {
    id: Float,
    rating: Float,
    ?name: String
}

typedef RatingMessage = {
    rating: Float,
    ?ratingCategory: Array<RatingCategory>,
    ?learner: LearnerMessage
}
