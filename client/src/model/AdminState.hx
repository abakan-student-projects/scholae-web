package model;

import model.Role;
import messages.AdminMessage;
import utils.RemoteData;

typedef AdminState = {
    users: RemoteData<Array<AdminMessage>>,
}