package model;

import messages.AdminMessage;
import utils.RemoteData;

typedef AdminState = {
    users: RemoteData<Array<AdminMessage>>
}