package model;

import sys.db.Manager;
import sys.db.Types;

@:table("Attempts")
class Attempt extends sys.db.Object {
    public var id: SBigId;
    @:relation(taskId) public var task : CodeforcesTask;
    @:relation(userId) public var user : User;
    public var description: SSmallText;
    public var solved: SBool;

    public function new() {
        super();
    }

    public static var manager = new Manager<Attempt>(Attempt);
    
}
