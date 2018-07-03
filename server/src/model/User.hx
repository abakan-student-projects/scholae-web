package model;

import sys.db.Types;

@:table("users")
class User extends sys.db.Object {
    public var id: SBigId;
    public var email: SString<512>;
    public var passwordHash: SString<128>;
    public function new() {
        super();
    }
}
