package model;

import messages.UserMessage;
import utils.RemoteData;

typedef AdminState = {
    users: RemoteData<Array<UserMessage>>
}