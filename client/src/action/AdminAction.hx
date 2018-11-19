package action;

import model.Role.Roles;
import messages.AdminMessage;

enum AdminAction {

    Clear;

    LoadUsers;
    LoadUsersFinished(users: Array<AdminMessage>);

    UpdateRoleUsers(user: AdminMessage);
    UpdateRoleUsersFinished(user: AdminMessage);

}
