package action;

import messages.TrainingMessage;
import messages.GroupMessage;
import messages.LearnerMessage;

enum LearnerAction {

    Clear;

    SignUpToGroup(key: String);
    SignUpToGroupFinished(group: GroupMessage);
    SignUpRedirect(to: String);

    LoadTrainings;
    LoadTrainingsFinished(trainings: Array<TrainingMessage>);

    RefreshResults;
    RefreshResultsFinished(trainings: Array<TrainingMessage>);
}
