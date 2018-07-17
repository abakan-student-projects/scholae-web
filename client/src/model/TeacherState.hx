package model;

import messages.LearnerMessage;
import utils.RemoteData;
import messages.GroupMessage;

typedef TeacherState = {
    groups: RemoteData<Array<GroupMessage>>,
    currentGroup: {
        info: GroupMessage,
        learners: RemoteData<Array<LearnerMessage>>
    },
    showNewGroupView: Bool,
}