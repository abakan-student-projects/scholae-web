package model;

import sys.db.Manager;

@:table("CodeforcesTasksTags")
@:id(taskId, tagId)
class CodeforcesTaskTag extends sys.db.Object {

    @:relation(tagId) public var tag : CodeforcesTag;
    @:relation(taskId) public var task : CodeforcesTask;


    public function new() {
        super();
    }

    public static var manager = new Manager<CodeforcesTaskTag>(CodeforcesTaskTag);

}
