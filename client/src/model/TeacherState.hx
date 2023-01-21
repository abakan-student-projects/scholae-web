package model;

import messages.RatingMessage;
import messages.ArrayChunk;
import messages.TaskMessage;
import messages.AttemptMessage;
import haxe.ds.StringMap;
import messages.TrainingMessage;
import messages.AssignmentMessage;
import messages.TagMessage;
import messages.LearnerMessage;
import utils.RemoteData;
import messages.GroupMessage;

typedef TeacherState = {
    groups: RemoteData<Array<GroupMessage>>,
    currentGroup: {
        info: GroupMessage,
        learners: RemoteData<Array<LearnerMessage>>,
        assignments: RemoteData<Array<AssignmentMessage>>,
        trainings: RemoteData<Array<TrainingMessage>>,
        trainingsByUsersAndAssignments: StringMap<StringMap<Array<TrainingMessage>>>,
        rating: RemoteData<Array<RatingMessage>>
    },
    ratingByPeriod: RemoteData<Array<RatingMessage>>,
    showNewGroupView: Bool,
    tags: RemoteData<Array<TagMessage>>,
    lastLearnerAttempts: RemoteData<Array<AttemptMessage>>,
    assignmentCreating: Bool,
    trainingsCreating: Bool,
    resultsRefreshing: Bool,
    newAssignment: {
        possibleTasks: RemoteData<ArrayChunk<TaskMessage>>
    }
}