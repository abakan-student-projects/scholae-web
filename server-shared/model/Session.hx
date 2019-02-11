package model;

import utils.StringUtils;
import sys.db.Manager;
import sys.db.Types;

@:id(id)
@:table("sessions")
class Session extends sys.db.Object {
    public var id: SString<255>;
    @:relation(userId) public var user: User;
    public var clientIP: SString<25>;
    public var lastRequestTime: SDateTime;

    public static var manager = new Manager<Session>(Session);
    private static var keyLength = 25;

    public function new(user: User) {
        super();

        var id = generateId();
        while (null != manager.select({id: id}, null, false)) {
            id = generateId();
        }

        this.id = id;
        this.user = user;
    }

    private static function generateId(): String {
        var now = DateTools.format(Date.now(), "%Y%m%d%H%M%S");
        var randomPrefix = StringUtils.getRandomString(StringUtils.alphaNumeric, keyLength);
        return randomPrefix + now;
    }

    public static function findSession(sessionId: String): Session {
        var sessions = manager.search( { id: sessionId } );
        return if (sessions.length > 0) sessions.first() else null;
    }

    public static function getSessionByUser(user: User): Session {
        var sessions = manager.search( { userId : user.id }, true );
        var s = if (sessions.length > 0) sessions.first() else new Session(user);
        return s;
    }

    private static var _current: Session;
    public static function getCurrent(sessionId: String): Session {
        if (null == _current || _current.id != sessionId) {
            _current = if (null != sessionId) findSession(sessionId) else null;
        }
        return _current;
    }
}
