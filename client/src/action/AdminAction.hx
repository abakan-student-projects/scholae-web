package action;

import messages.AdminMessage;
import messages.ArrayChunk;

enum AdminAction {

    Clear;

    LoadUsers;
    LoadUsersFinished(users: Array<AdminMessage>);

/*    UpdateRoleUsers(users: AdminMessage);
    UpdateRoleUsersFinished(users: AdminMessage);*/

}
