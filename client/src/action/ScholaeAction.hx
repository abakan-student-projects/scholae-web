package action;

import messages.ProfileMessage;
import messages.SessionMessage;
import messages.LearnerMessage;
import messages.GroupMessage;
import messages.ResponseMessage;

enum ScholaeAction {

    Clear;

    //Authentication
    PreventLoginRedirection;
    Authenticate(email: String, password: String);
    Authenticated(sessionMessage: SessionMessage);
    AuthenticationFailed(failMessage: ResponseMessage);

    //Registration
    Register(email: String, password: String, codeforcesId: String, firstName: String, lastName: String);
    RegisteredAndAuthenticated(sessionMessage: SessionMessage);
    RegistrationFailed(message: String);
    PreventRegistrationRedirection;

    RenewPassword(email: String);

    UpdateAutenticationData;
    UpdateAutenticationDataFinished(sessionMessage: SessionMessage);

    EmailActivationCode(code: String);
    EmailActivationCodeFinished(check: Bool);
}
