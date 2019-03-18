package service;

import model.UserAchievement;
import configuration.Configuration;
import php.Web;
import codeforces.Codeforces;
import messages.PasswordMessage;
import sys.db.Manager;
import messages.ProfileMessage;
import service.ServiceHelper;
import model.Role;
import model.Role.Roles;
import messages.ResponseMessage;
import messages.UserMessage;
import haxe.crypto.Md5;
import utils.StringUtils;
import messages.SessionMessage;
import model.Session;
import model.User;
import php.Lib.mail;


class AuthService {

    public function new() {}

    /**
    * return Session ID, String
    **/
    public function authenticate(email: String, password: String): ResponseMessage {
        var user = User.getUserByEmailAndPassword(email, password);
        if (null != user) {
            if (canAuth(user.activationDate, user.emailActivated)) {
                var session = Session.getSessionByUser(user);
                if (null != session && null != Session.manager.search({ id: session.id }).first()){
                    updateClientInfo(session);
                } else {
                    session.clientIP = Web.getClientIP();
                    session.lastRequestTime = Date.now();
                    session.insert();
                }
                return ServiceHelper.successResponse(user.toSessionMessage(session.id));
            } else return ServiceHelper.failResponse("You can't sign in. The email activation period has expired.");
        }
        return ServiceHelper.failResponse("Email or password is wrong.");
    }

    public function canAuth(date: Date, emailActivated: Bool): Bool {
        return
            if (emailActivated) true;
            else
                if (Date.now().getTime() <= DateTools.delta(date, (86400 * 1000) * 7).getTime()) true;
            else false;
    }

    private function updateClientInfo(session: Session): Void {
        session.clientIP = Web.getClientIP();
        session.lastRequestTime = Date.now();
        session.update();
    }

    public function checkSession(sessionId: String): ResponseMessage {
        var session: Session = Session.findSession(sessionId);
        if (null != session){
            updateClientInfo(session);
            return ServiceHelper.successResponse(session.user.toSessionMessage(session.id));
        } else {
            return ServiceHelper.failResponse("Session not found.");
        }
    }

    public function doesEmailExist(email: String): Bool {
        return User.manager.count($email == email) > 0;
    }

    public function doesCodeforcesHandleExist(codeforcesHandle: String): Bool {
        return User.manager.count($codeforcesHandle == codeforcesHandle) > 0;
    }

    public function isCodeforcesHandleValid(codeforcesHandle: String): Bool {
        return(Codeforces.getCodeForcesHandle(codeforcesHandle) == null );
    }

    public function renewPassword(email: String): ResponseMessage {
        var user: User = User.manager.select($email == email, true);
        var subjectForUser ='Scholae: измение пароля';
        var password = StringUtils.getRandomString(StringUtils.alphaNumeric, 8);
        var template = new haxe.Template(haxe.Resource.getString("renewPasswordEmail"));
        var message = template.execute({password: password});
        var from = "From: " + Configuration.instance.getEmailNotification();
        if (null != user) {
            var res = mail(user.email, subjectForUser, message, from);
            user.passwordHash = Md5.encode(password);
            user.update();
            return ServiceHelper.successResponse(res);
        }
        else return ServiceHelper.successResponse(false);
    }

    private function greetUser(user: User) {
        var subjectForUser ='Scholae: здравствуйте!';
        var template = new haxe.Template(haxe.Resource.getString("activationEmail"));
        var message = template.execute({isRegistration: true, activationCode: user.emailActivationCode});
        var from = "From: " + Configuration.instance.getEmailNotification();
        mail(user.email, subjectForUser, message, from);
    }

    public function registerAndAuthenticateUser(user: UserMessage): ResponseMessage {
        if (doesEmailExist(user.email)) {
            return ServiceHelper.failResponse("Email already exists.");
        } else if (doesCodeforcesHandleExist(user.codeforcesHandle)) {
            return ServiceHelper.failResponse("Codeforces Handle already exists.");
        } else if (isCodeforcesHandleValid(user.codeforcesHandle)) {
            return ServiceHelper.failResponse("Codeforces user with handle " + user.codeforcesHandle + " not found");
        } else {
            var u: User = new User();
            u.email = user.email;
            u.firstName = user.firstName;
            u.lastName = user.lastName;
            u.passwordHash = Md5.encode(user.password);
            u.registrationDate = Date.now();
            u.activationDate = Date.now();
            u.roles.set(Role.Learner);
            u.codeforcesHandle = user.codeforcesHandle;
            u.emailActivationCode = Md5.encode(Std.string(u.registrationDate));
            u.insert();
            greetUser(u);

            return authenticate(user.email, user.password);
        }
    }

    public function emailActivation(code: String): Bool {
        var user: User = User.manager.select($emailActivationCode == code, true);
        if (user != null) {
            user.emailActivationCode = null;
            user.emailActivated = true;
            user.update();

            return true;
        }

        return false;
    }

    public function getAuthenticationData(): ResponseMessage {
        var user: User = Authorization.instance.currentUser;
        if (user != null) {
            var session = Session.getSessionByUser(user);
            return ServiceHelper.successResponse(user.toSessionMessage(session.id));
        }
        return ServiceHelper.failResponse("Getting authentication data failed");
    }

    public function getProfile(): ResponseMessage {
        var user: User = Authorization.instance.currentUser;
        if (user != null) {
            return ServiceHelper.successResponse(user.toProfileMessage());
        }
        return ServiceHelper.failResponse("Getting profile data failed");
    }

    public function updateProfile(profileMessage: ProfileMessage): ResponseMessage {
        var user: User = User.manager.select($id == Authorization.instance.currentUser.id, true);
        if (user != null) {
            if (profileMessage.codeforcesHandle != null) {
                if(isCodeforcesHandleValid(profileMessage.codeforcesHandle)) {
                    return ServiceHelper.failResponse("Codeforces user with handle " + profileMessage.codeforcesHandle + " not found");
                }
                else if(!doesCodeforcesHandleExist(profileMessage.codeforcesHandle)) {
                    user.codeforcesHandle = profileMessage.codeforcesHandle;
                } else {
                    return ServiceHelper.failResponse("Codeforces Handle already exists");
                }
            }
            if (profileMessage.firstName != null) {
                user.firstName = profileMessage.firstName;
            }
            if (profileMessage.lastName != null) {
                user.lastName = profileMessage.lastName;
            }
            user.update();
            return ServiceHelper.successResponse(user.toProfileMessage());
        }
        return ServiceHelper.failResponse("Profile update failed");
    }

    public function updateEmail(profileMessage: ProfileMessage): ResponseMessage {
        var user: User = User.manager.select($id == Authorization.instance.currentUser.id, true);
        if (user != null) {
            if(!doesEmailExist(profileMessage.email)) {
                user.email = profileMessage.email;
                var date = Date.now();
                user.activationDate = date;
                user.emailActivationCode = Md5.encode(Std.string(date));
                user.emailActivated = false;
                user.update();
                sendActivationEmail();
                return ServiceHelper.successResponse(user.toProfileMessage());
            } else {
                return ServiceHelper.failResponse("Email already exists");
            }
        }
        return ServiceHelper.failResponse("Email update failed");
    }

    public function sendActivationEmail(): ResponseMessage {
        var user: User = Authorization.instance.currentUser;
        if (null != user) {
            var subjectForUser ='Scholae: подтверждение почты!';
            var template = new haxe.Template(haxe.Resource.getString("activationEmail"));
            var message = template.execute({isRegistration: false, activationCode: user.emailActivationCode});
            var from = "From: " + Configuration.instance.getEmailNotification();
            var res = mail(user.email, subjectForUser, message, from);
            return ServiceHelper.successResponse(res);
        }
        else return ServiceHelper.successResponse(false);
    }

    public function updatePassword(passwordMessage: PasswordMessage): ResponseMessage {
        var sessionId = Web.getParams().get("sid");
        var user: User = User.manager.select($id == Session.getCurrent(sessionId).user.id, true);
        if (null != user) {
            if(passwordMessage.oldPassword == user.passwordHash) {
                user.passwordHash = passwordMessage.newPassword;
                user.update();
                return ServiceHelper.successResponse(true);
            } else {
                return ServiceHelper.failResponse("Не правильный текущий пароль");
            }
        }
        else return ServiceHelper.failResponse("Не удалось изменить пароль");
    }

    public function getAchievements(): ResponseMessage {
        return ServiceHelper.authorize(Role.Learner, function() {
            return ServiceHelper.successResponse(
                Lambda.array(
                    Lambda.map(
                        UserAchievement.getUserAchievements(Authorization.instance.currentUser),
                        function(t: UserAchievement) { return t.toMessage();}
                    )
                )
            );
        });
    }
}
