package model;

import messages.GroupMessage;
import sys.db.Manager;
import sys.db.Types;

@:table("Groups")
class Group extends sys.db.Object {

    public var id: SBigId;
    public var name: SString<512>;
    public var signUpKey: SString<512>;
    public var deleted: SBool;

    @:relation(teacherId) public var teacher : User;

    public function new() {
        super();
    }

    public static var manager = new Manager<Group>(Group);

    public static function getGroupsByTeacher(teacher: User): List<Group> {
        return manager.search($teacherId == teacher.id, false);
    }

    public static function getGroupBySignUpKey(key: String): Group {
        return manager.select($signUpKey == key, false);
    }

    public function toMessage(): GroupMessage {
        return {
            id: id,
            name: name,
            signUpKey: signUpKey,
            deleted: deleted
        };
    }
}
