package action;

import messages.SessionMessage;
import messages.LearnerMessage;
import messages.GroupMessage;

enum ScholaeAction {

    Clear;

    //Authentication
    PreventLoginRedirection;
    Authenticate(email: String, password: String);
    Authenticated(sessionMessage: SessionMessage);
    AuthenticationFailed;

    //Registration
    Register(email: String, password: String, codeforcesId: String, firstName: String, lastName: String);
    RegisteredAndAuthenticated(sessionId: String);
    PreventRegistrationRedirection;

    RenewPassword(email: String);
}
