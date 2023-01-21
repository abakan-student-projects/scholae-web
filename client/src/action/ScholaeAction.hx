package action;

import achievement.AchievementMessage;
import messages.PasswordMessage;
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

    GetProfile;
    UpdateProfile(profileMessage: ProfileMessage);
    UpdateProfileFinished(profileMessage: ProfileMessage);
    UpdateEmail(profileMessage: ProfileMessage);
    UpdateEmailFinished(profileMessage: ProfileMessage);
    UpdatePassword(passwordMessage: PasswordMessage);

    EmailActivationCode(code: String);
    EmailActivationCodeFinished(check: Bool);
    SendActivationEmail;

    GetAchievements;
    GetAchievementsFinished(achievements: Array<AchievementMessage>);
}
