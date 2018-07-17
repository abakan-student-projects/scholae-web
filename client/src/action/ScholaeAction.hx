package action;

import messages.LearnerMessage;
import messages.GroupMessage;

enum ScholaeAction {

    //Authentication
    PreventLoginRedirection;
    Authenticate(email: String, password: String);
    Authenticated(email: String, sessionId: String);
    AuthenticationFailed;

    //Registration
    Register(email: String, password: String, codeforcesId: String, firstName: String, lastName: String);
    RegisteredAndAuthenticated(sessionId: String);
    PreventRegistrationRedirection;
}
