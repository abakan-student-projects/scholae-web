package action;

import messages.TrainingMessage;
import messages.AssignmentMessage;
import messages.TagMessage;
import messages.GroupMessage;
import messages.LearnerMessage;

enum TeacherAction {
    LoadGroups;
    LoadGroupsFinished(groups: Array<GroupMessage>);
    AddGroup(name: String, signUpKey: String);
    GroupAdded(group: GroupMessage);
    ShowNewGroupView;
    HideNewGroupView;

    SetCurrentGroup(group: GroupMessage);
    LoadLearnersByGroupFinished(learners: Array<LearnerMessage>);
    LoadAssignmentsByGroupFinished(assignments: Array<AssignmentMessage>);

    LoadAllTags;
    LoadAllTagsFinished(tags: Array<TagMessage>);

    CreateAssignment(group: GroupMessage, assignment: AssignmentMessage);
    CreateAssignmentFinished(assignment: AssignmentMessage);

    CreateTrainingsByMetaTrainings(groupId: Float);
    CreateTrainingsByMetaTrainingsFinished(assignments: Array<AssignmentMessage>);

    LoadTrainings(groupId: Float);
    LoadTrainingsFinished(trainings: Array<TrainingMessage>);

    RefreshResults(groupId: Float);
    RefreshResultsFinished(trainings: Array<TrainingMessage>);
}
