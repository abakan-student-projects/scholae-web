package model;

import messages.GroupMessage;
import utils.RemoteData;

typedef LearnerState = {
    groups: RemoteData<Array<GroupMessage>>,

    currentGroup: {
        info: GroupMessage,
    },

    signup: {
        redirectTo: String
    }
}