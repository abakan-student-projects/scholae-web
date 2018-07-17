package model;

import model.Role.Roles;

typedef AuthState = {
    loggedIn: Bool,
    email: String,
    sessionId: String,
    returnPath: String,
    firstName: String,
    lastName: String,
    roles: Roles
}