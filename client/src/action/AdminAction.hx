package action;

import model.Role.Roles;
import messages.AdminMessage;
import messages.ArrayChunk;

enum AdminAction {

    Clear;

    LoadUsers;
    LoadUsersFinished(users: Array<AdminMessage>);

    UpdateRoleUsers(role: Roles);
    UpdateRoleUsersFinished(role: Roles);

}
