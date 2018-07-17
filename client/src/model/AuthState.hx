package model;

import model.Role.Roles;

typedef AuthState = {
    loggedIn: Bool,
    email: String,
    sessionId: String,
    returnPath: String,
    name: String,
    lastname: String,
    roles: Roles
}