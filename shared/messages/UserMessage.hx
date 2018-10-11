package messages;

import model.Role.Roles;

typedef UserMessage = {
    id: Float,
    email: String,
    firstName: String,
    lastName: String,
    codeforcesHandle: String,
    ?password: String,
    roles: Roles, 
    ?rating: Float
}
