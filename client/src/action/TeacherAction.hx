package action;

import messages.GroupMessage;
import messages.LearnerMessage;

enum TeacherAction {

    LoadGroups;
    LoadGroupsFinished(groups: Array<GroupMessage>);
    AddGroup(name: String, signUpKey: String);
    GroupAdded(group: GroupMessage);
    ShowNewGroupView;
    HideNewGroupView;

    LoadLearnersByGroup(groupId: Float);
    LoadLearnersByGroupFinished(learners: Array<LearnerMessage>);
}
