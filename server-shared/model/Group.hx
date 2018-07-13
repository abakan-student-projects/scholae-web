package model;

import sys.db.Manager;
import sys.db.Types;

@:table("Groups")
class Group extends sys.db.Object {

    public var id: SBigId;
    public var name: SString<512>;
    public var signUpKey: SString<512>;

    @:relation(teacherId) public var teacher : User;

    public function new() {
        super();
    }

    public static var manager = new Manager<Group>(Group);

    public static function getGroupsByTeacher(teacher: User): List<Group> {
        return manager.search($teacherId == teacher.id);
    }
}
