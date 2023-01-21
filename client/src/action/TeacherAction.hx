package action;

import Array;
import messages.RatingMessage;
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
    LoadRatingLearnersByGroupFinished(rating: Array<RatingMessage>);

    LoadAllTags;
    LoadAllTagsFinished(tags: Array<TagMessage>);

    LoadLastLearnerAttempts;
    LoadLastLearnerAttemptsFinished(attempts: Array<AttemptMessage>);

    CreateAssignment(group: GroupMessage, assignment: AssignmentMessage);
    CreateAdaptiveAssignment(group: GroupMessage, name: String, startDate: Date, finishDate: Date, tasksCount: Int, learnerIds: Array<Float>);
    CreateAssignmentFinished(assignment: AssignmentMessage);

    CreateTrainingsByMetaTrainings(groupId: Float);
    CreateTrainingsByMetaTrainingsFinished(assignments: Array<AssignmentMessage>);

    LoadTrainings(groupId: Float);
    LoadTrainingsFinished(trainings: Array<TrainingMessage>);

    RefreshResults(groupId: Float);
    RefreshResultsFinished(trainings: Array<TrainingMessage>);

    LoadPossibleTasks(metaTraining: MetaTrainingMessage, ?filter: String);
    LoadPossibleTasksFinished(tasks: ArrayChunk<TaskMessage>);

    DeleteLearnerFromCourse(learnerId: Float, groupId: Float);
    DeleteLearnerFromCourseFinished(learnerId: Float);

    DeleteCourse(groupId: Float);
    DeleteCourseFinished(groupId: Float);

    LoadRatingsForCourse(userIds: Array<Float>, startDate: Date, finishDate: Date);
    LoadRatingsForCourseFinished(rating: Array<RatingMessage>);

    SortDeltaRatingByPeriod;
    SortSolvedTasksByPeriod;
    SortLearnersByPeriod;
}
