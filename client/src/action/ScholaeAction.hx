package action;

enum ScholaeAction {

    //Authentication
    PreventLoginRedirection;
    Authenticate(email: String, password: String);
    Authenticated(email: String, sessionId: String);
    AuthenticationFailed;

    //Registration
    Register(email: String, password: String, codeforcesId: String);
    RegisteredAndAuthenticated(sessionId: String);
    PreventRegistrationRedirection;
}
