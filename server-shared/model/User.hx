package model;

import messages.LearnerMessage;
import haxe.crypto.Md5;
import sys.db.Manager;
import sys.db.Types;

@:table("users")
class User extends sys.db.Object {
    public var id: SBigId;
    public var email: SString<512>;
    public var firstName: SString<128>;
    public var lastName: SString<128>;
    public var passwordHash: SString<128>;
    public var roles: SFlags<Role>;

    public function new() {
        super();
        roles.set(Role.Learner);
    }

    public static var manager = new Manager<User>(User);

    public static function getUserByEmailAndPassword(email: String, password: String) {
        var users = manager.search( {
            email: email,
            passwordHash: Md5.encode(password)
        });
        return if (users.length > 0) users.first() else null;
    }

    public function toLearnerMessage(): LearnerMessage {
        return
            {
                id: id,
                email: email,
                firstName: firstName,
                lastName: lastName
            };
    }
}
