package model;

import messages.TaskMessage;
import sys.db.Types;
import sys.db.Manager;

@:table("CodeforcesTasks")
class CodeforcesTask extends sys.db.Object {
    public var id: SBigId;
    public var name: SString<512>;
    public var level: SInt;
    public var solvedCount: Int;
    public var contestId: Int;
    public var contestIndex: SString<128>;
    public var type: SString<128>;

    public function new() {
        super();
    }

    public static var manager = new Manager<CodeforcesTask>(CodeforcesTask);

    public static function getOrCreateByCodeforcesProblem(p: codeforces.Problem): CodeforcesTask {
        var task: CodeforcesTask = manager.select({ contestId: p.contestId, contestIndex: p.index });
        var isNew = false;

        if (null == task) {
            task = new CodeforcesTask();
            task.contestId = p.contestId;
            task.contestIndex = p.index;
            task.insert();
        }

        task.name = p.name;
        return task;
    }

    public static function doTasksExistForContest(contestId: Int): Bool {
        return manager.count($contestId == contestId) > 0;
    }

    public function isGymTask(): Bool {
        return contestId >= 100000;
    }

    public function toMessage(): TaskMessage {
        return {
            id: id,
            name: name,
            level: level,
            tagIds: Lambda.array(Lambda.map(CodeforcesTaskTag.manager.search($taskId == id), function(t) { return t.tag.id; }))
        };
    }
}
