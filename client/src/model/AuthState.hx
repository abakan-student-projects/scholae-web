package model;

import router.RouterLocation;

typedef AuthState = {
    loggedIn: Bool,
    email: String,
    sessionId: String,
    returnPath: String
}