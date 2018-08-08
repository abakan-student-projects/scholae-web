package action;

import messages.GroupMessage;
import messages.LearnerMessage;

enum LearnerAction {

    Clear;

    SignUpToGroup(key: String);
    SignUpToGroupFinished(group: GroupMessage);
    SignUpRedirect(to: String);
}
