package model;

import haxe.ds.StringMap;

class ModelUtils {

    public static function getTasksSolvedByUser(user: User): List<CodeforcesTask> {
        return Lambda.map(Attempt.manager.search($userId == user.id && $solved == true), function(a) { return a.task; });
    }

    public static function getTaskIdsByTags(tagIds: Array<Float>): StringMap<Bool> {
        var res = new StringMap<Bool>();
        var relations = CodeforcesTaskTag.manager.search($tagId in tagIds);
        for (r in relations) {
            res.set(Std.string(r.task.id), true);
        }
        return res;
    }

    public static function getTasksForUser(user: User, minLevel: Int, maxLevel: Int, tagIds: Array<Float>, length: Int): Array<CodeforcesTask> {
        var solvedTaskIds: List<Float> = Lambda.map(getTasksSolvedByUser(user), function(t) { return t.id; });

        var taskIdsByTags = getTaskIdsByTags(tagIds);

        var tasks: Array<CodeforcesTask> =
                Lambda.array(
                    Lambda.filter(
                        CodeforcesTask.manager.search($level >= minLevel && $level <= maxLevel && !($id in solvedTaskIds)),
                        function(t) { return taskIdsByTags.exists(Std.string(t.id)); }));

        if (tasks.length < length) return null;

        var res = [];
        for (i in 0...length) {
            res.push(getRandomItemAndRemoveItFromList(tasks));
        }

        return res;
    }

    private static function getRandomItemAndRemoveItFromList<T>(a: Array<T>): T {
        var i = Math.round(Math.random() * (a.length - 1));
        var res = a[i];
        a.remove(res);
        return res;
    }
}
