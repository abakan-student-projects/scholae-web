package action;

import model.Role.Roles;
import messages.UserMessage;

enum AdminAction {

    Clear;

    LoadUsers;
    LoadUsersFinished(users: Array<UserMessage>);

    UpdateRoleUsers(user: UserMessage);
    UpdateRoleUsersFinished(user: UserMessage);
}
