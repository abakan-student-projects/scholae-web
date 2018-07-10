package model;

import php.Web;
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
        updateClientInfo();
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
        s.updateClientInfo();
        return s;
    }

    public static var current(get, null): Session;
    private static var _current: Session;
    private static function get_current() {
        var sessionId = Web.getParams().get("sid");
        if (null == _current || _current.id != sessionId) {
            _current = if (null != sessionId) findSession(sessionId) else null;
        }
        return _current;
    }

    private function updateClientInfo() {
        this.clientIP = Web.getClientIP();
        this.lastRequestTime = Date.now();
    }

}
