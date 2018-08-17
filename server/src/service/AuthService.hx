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

    public function RenewalPasswordEmailToUser(email: String): Bool {
        var user = email;
        var messageEmail = false;
        var subjectForUser='Scholae: измение пароля';
        var messageForUser = '
                            Здравствуйте,

                            ваш новый пароль: [password].

                            С уважением,
                            Scholae
                            ';
        var from = 'no-reply@scholae.lambda-calculus.ru';
        if (null != user) {
            messageEmail = mail (user, subjectForUser, messageForUser, from);
            return messageEmail;
        }
        else return null;
    }


}
