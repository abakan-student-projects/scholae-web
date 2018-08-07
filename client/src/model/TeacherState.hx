package model;

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
        trainingsByUsersAndAssignments: StringMap<StringMap<Array<TrainingMessage>>>
    },
    showNewGroupView: Bool,
    tags: RemoteData<Array<TagMessage>>,
    assignmentCreating: Bool,
    trainingsCreating: Bool,
    resultsRefreshing: Bool
}