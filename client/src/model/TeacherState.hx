package model;

import messages.GroupMessage;

typedef TeacherState = {
    groups: Array<GroupMessage>,
    showNewGroupView: Bool,
    loading: Bool
}