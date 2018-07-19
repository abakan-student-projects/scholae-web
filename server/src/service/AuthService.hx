package service;

import messages.SessionMessage;
import model.Session;
import model.User;
import php.Lib.mail;

class AuthService {

    public function new() {}

    /**
    * return Session ID, String
    **/
    public function authenticate(email: String, password: String): String {
        var user = User.getUserByEmailAndPassword(email, password);
        if (null != user) {
            var session = Session.getSessionByUser(user);
            if (null != session && null != Session.manager.search({ id: session.id }).first()) session.update() else session.insert();
            return session.id;
        }
        return null;
    }

    public function checkSession(sessionId: String): SessionMessage {
        var session: Session = Session.findSession(sessionId);

        return
            if (null != session)
                {
                    userId: session.user.id,
                    email: session.user.email
                }
            else
                null;
    }

    public function returnPassword(email: String): Bool {
        var user = email;
        var messageEmail = false;
        var subjectForUser='Смена пароля';
        var messageForUser = 'Тут скоро мы будем присылать вам пароль';
        var from = 'test@test.ru';
        if (null != user) {
            messageEmail = mail (user, subjectForUser, messageForUser, from);
            return messageEmail;
        }
        else return null;
    }


}
