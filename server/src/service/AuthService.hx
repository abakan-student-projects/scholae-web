package service;

import service.ServiceHelper;
import service.ServiceHelper;
import service.ServiceHelper;
import service.ServiceHelper;
import service.ServiceHelper;
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
            var session = Session.getSessionByUser(user);
            if (null != session && null != Session.manager.search({ id: session.id }).first()) session.update() else session.insert();
            return ServiceHelper.successResponse(user.toSessionMessage(session.id));
        }
        return ServiceHelper.failResponse("Email or password is wrong.");
    }

    public function checkSession(sessionId: String): ResponseMessage {
        var session: Session = Session.findSession(sessionId);
        return
            if (null != session)
                ServiceHelper.successResponse(session.user.toSessionMessage(session.id))
            else
                ServiceHelper.failResponse("Session not found.");
    }

    public function doesEmailExist(email: String): Bool {
        return User.manager.count($email == email) > 0;
    }

    public function doesCodeforcesHandleExist(codeforcesHandle: String): Bool {
        return User.manager.count($codeforcesHandle == codeforcesHandle) > 0;
    }

    public function isCodeforcesHandleValid(codeforcesHandle: String): Bool {
        //TODO: implement
        //use https://codeforces.com/api/help/methods#user.info to check if user exists
        return true;
    }

    public function renewPassword(email: String): ResponseMessage {
        var user: User = User.manager.select($email == email, true);
        var subjectForUser ='Scholae: измение пароля';
        var password = StringUtils.getRandomString(StringUtils.alphaNumeric, 8);
        var message = 'Здравствуйте,

ваш новый пароль: $password.

С уважением,
Scholae';
        var from = 'From: no-reply@scholae.lambda-calculus.ru';
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
        var message = 'Здравствуйте,
мы рады, что вы зарегистрировались в Scholae!
Перейдите по ссылке для подтверждения электронной почты - http://scholae.lambda-calculus.ru/activation/${user.emailActivationCode}
Активация электронной почты доступна в течении 7 дней (со дня регистрации - ${user.registrationDate}).

Удачи в тренировках!

С уважением,
Scholae';
        var from = 'From: no-reply@scholae.lambda-calculus.ru';
        mail(user.email, subjectForUser, message, from);
    }

    public function registerAndAuthenticateUser(user: UserMessage): ResponseMessage {
        if (doesEmailExist(user.email)) {
            return ServiceHelper.failResponse("Email already exists.");
        } else if (doesCodeforcesHandleExist(user.codeforcesHandle)) {
            return ServiceHelper.failResponse("Codeforces Handle already exists.");
        } else {
            var u: User = new User();
            u.email = user.email;
            u.firstName = user.firstName;
            u.lastName = user.lastName;
            u.passwordHash = Md5.encode(user.password);
            u.registrationDate = Date.now();
            u.roles.set(Role.Learner);
            u.codeforcesHandle = user.codeforcesHandle;
            u.emailActivationCode = Md5.encode(Std.string(u.registrationDate));
            u.insert();
            greetUser(u);

            return authenticate(user.email, user.password);
        }
    }

    function parseDateParts(date: Date): Dynamic {
        return {
            y: Std.parseInt(DateTools.format(date, "%Y")),
            M: Std.parseInt(DateTools.format(date, "%m")),
            d: Std.parseInt(DateTools.format(date, "%d")),
            h: Std.parseInt(DateTools.format(date, "%H")),
            m: Std.parseInt(DateTools.format(date, "%M")),
            s: Std.parseInt(DateTools.format(date, "%S"))
        }
    }

    public function checkDateActivation(date: Date): Bool {
        var dateRParse = parseDateParts(date);
        var dateDeadlineActivated: Float = DateTools.makeUtc(dateRParse.y,dateRParse.M - 1,dateRParse.d + 7,dateRParse.h,dateRParse.m,dateRParse.s) / 1000;

        var dateCPase = parseDateParts(Date.now());
        var dateCurrent: Float = DateTools.makeUtc(dateCPase.y,dateCPase.M - 1,dateCPase.d,dateCPase.h,dateCPase.m,dateCPase.s) / 1000;

        // if current date < deadline date then return true, else false
        if (dateCurrent <= dateDeadlineActivated) return true
        else return false;
    }

    public function emailActivation(code: String): Bool {
        var user: User = User.manager.select($emailActivationCode == code, true);
        if (user != null) {
            if (checkDateActivation(user.registrationDate)) {
                user.emailActivationCode = null;
                user.emailActivated = true;
                user.update();

                return true;
            } else false;
        }

        return false;
    }
}
