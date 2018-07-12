package model;

import model.CodeforcesTag;
@:table("CodeforcesTasksTags")
@:id(tagId,taskId)
class CodeforcesTaskTag extends sys.db.Object {

    @:relation(tagId) public var tag : CodeforcesTag;
    @:relation(taskId) public var task : CodeforcesTask;


    public function new() {
        super();
    }

    public static var manager = new Manager<CodeforcesTaskTag>(CodeforcesTaskTag);

}
