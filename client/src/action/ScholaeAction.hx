package action;

enum ScholaeAction {
    PreventLoginRedirection;
    Authenticate(email: String, password: String);
    Authenticated(email: String, sessionId: String);
    AuthenticationFailed;
}
