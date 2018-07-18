package action;

import messages.GroupMessage;
import messages.LearnerMessage;

enum LearnerAction {
    SignUpToGroup(key: String);
    SignUpToGroupFinished(group: GroupMessage);
    SignUpRedirect(to: String);
}
