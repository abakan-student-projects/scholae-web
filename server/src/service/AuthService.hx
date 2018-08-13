package service;

import messages.SessionMessage;
import model.Session;
import model.User;

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
    }

    public function doesCodeforcesHandleExist(codeforcesHandle: String): Bool {
        //TODO: implement
    }

    public function isCodeforcesHandleValid(codeforcesHandle: String): Bool {
        //TODO: implement
        //use https://codeforces.com/api/help/methods#user.info to check if user exists
    }
}
