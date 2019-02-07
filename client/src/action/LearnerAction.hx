package action;

import Array;
import messages.RatingMessage;
import messages.TrainingMessage;
import messages.GroupMessage;

enum LearnerAction {

    Clear;

    SignUpToGroup(key: String);
    SignUpToGroupFinished(group: GroupMessage);
    SignUpRedirect(to: String);

    LoadTrainings;
    LoadTrainingsFinished(trainings: Array<TrainingMessage>);
    LoadTrainingsFailed;

    RefreshResults;
    RefreshResultsFinished(trainings: Array<TrainingMessage>);

    LoadRating(?learnerId: Float);
    LoadRatingFinished(rating: Array<RatingMessage>);
}
