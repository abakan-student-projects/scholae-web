package model;

import sys.db.Manager;
import sys.db.Types;

@:table("GroupsLearners")
@:id(groupId, learnerId)
class GroupLearner extends sys.db.Object {
    @:relation(groupId) public var group : Group;
    @:relation(learnerId) public var learner : User;

    public function new() {
        super();
    }

    public static var manager = new Manager<GroupLearner>(GroupLearner);
}
