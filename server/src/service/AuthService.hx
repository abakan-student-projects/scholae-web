package service;

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
    public function authenticate(email: String, password: String): SessionMessage {
        var user = User.getUserByEmailAndPassword(email, password);
        if (null != user) {
            var session = Session.getSessionByUser(user);
            if (null != session && null != Session.manager.search({ id: session.id }).first()) session.update() else session.insert();
            return user.toSessionMessage(session.id);
        }
        return null;
    }

    public function checkSession(sessionId: String): SessionMessage {
        var session: Session = Session.findSession(sessionId);

        return
            if (null != session)
                session.user.toSessionMessage(session.id)
            else
                null;
    }

    public function doesEmailExist(email: String): Bool {
        //TODO: implement
        return true;
    }

    public function doesCodeforcesHandleExist(codeforcesHandle: String): Bool {
        //TODO: implement
        return true;
    }

    public function isCodeforcesHandleValid(codeforcesHandle: String): Bool {
        //TODO: implement
        //use https://codeforces.com/api/help/methods#user.info to check if user exists
        return true;
    }

    public function renewPassword(email: String): Bool {
        var user: User = User.manager.select($email == email, true);
        var messageEmail = false;
        var subjectForUser ='Scholae: измение пароля';
        var password = StringUtils.getRandomString(StringUtils.alphaNumeric, 8);
        var message = 'Здравствуйте,

ваш новый пароль: $password.

С уважением,
Scholae';
        var from = 'no-reply@scholae.lambda-calculus.ru';
        if (null != user) {
            messageEmail = mail(user.email, subjectForUser, message, from);
            user.passwordHash = Md5.encode(password);
            return messageEmail;
        }
        else return false;
    }
}
