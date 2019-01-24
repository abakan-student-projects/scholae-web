package action;

import messages.ProfileMessage;

enum ProfileAction {
    Clear;

    GetProfile;
    UpdateProfile(codeforcesHandle: String,  firstName: String, lastName: String);
    UpdateProfileFinished(profileMessage: ProfileMessage);
}