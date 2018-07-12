package model;

import haxe.crypto.Md5;
import sys.db.Manager;
import sys.db.Types;

@:table("users")
class User extends sys.db.Object {
    public var id: SBigId;
    public var email: SString<512>;
    public var passwordHash: SString<128>;
    public function new() {
        super();
    }

    public static var manager = new Manager<User>(User);

    public static function getUserByEmailAndPassword(email: String, password: String) {
        var users = manager.search( {
            email: email,
            passwordHash: Md5.encode(password)
        });
        return if (users.length > 0) users.first() else null;
    }
}
