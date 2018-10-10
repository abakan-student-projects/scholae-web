package action;

import model.TeacherState;
import messages.ArrayChunk;
import messages.TaskMessage;
import messages.MetaTrainingMessage;
import messages.AttemptMessage;
import messages.TrainingMessage;
import messages.AssignmentMessage;
import messages.TagMessage;
import messages.GroupMessage;
import messages.LearnerMessage;

enum TeacherAction {

    Clear;

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

    LoadLastLearnerAttempts;
    LoadLastLearnerAttemptsFinished(attempts: Array<AttemptMessage>);

    CreateAssignment(group: GroupMessage, assignment: AssignmentMessage);
    CreateAssignmentFinished(assignment: AssignmentMessage);

    CreateTrainingsByMetaTrainings(groupId: Float);
    CreateTrainingsByMetaTrainingsFinished(assignments: Array<AssignmentMessage>);

    LoadTrainings(groupId: Float);
    LoadTrainingsFinished(trainings: Array<TrainingMessage>);

    RefreshResults(groupId: Float);
    RefreshResultsFinished(trainings: Array<TrainingMessage>);

    LoadPossibleTasks(metaTraining: MetaTrainingMessage, ?filter: String);
    LoadPossibleTasksFinished(tasks: ArrayChunk<TaskMessage>);
}
