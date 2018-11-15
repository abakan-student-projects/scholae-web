package model;

import model.Role.Roles;
import messages.AdminMessage;
import utils.RemoteData;

typedef AdminState = {
    users: RemoteData<Array<AdminMessage>>,
    roles: Roles
}