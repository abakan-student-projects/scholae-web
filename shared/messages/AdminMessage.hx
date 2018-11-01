package messages;

import model.Role.Roles;

typedef AdminMessage = {
    userId: Float,
    email: String,
    firstName: String,
    lastName: String,
    roles: Roles
}
