package messages;

import model.Role.Roles;

typedef SessionMessage = {
    userId: Float,
    email: String,
    firstName: String,
    lastName: String,
    codeforcesHandle: String,
    roles: Roles,
    sessionId: String
}
