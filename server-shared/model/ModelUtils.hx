package model;

import haxe.io.Float64Array;
import haxe.macro.ExprTools.ExprArrayTools;
import Array;
import Lambda;
import haxe.ds.StringMap;

class ModelUtils {

    public static function getTasksSolvedByUser(user: User): List<CodeforcesTask> {
        return Lambda.filter(
            Lambda.map(
                Attempt.manager.search($userId == user.id && $solved == true),
                function(a) { return a.task; }),
            function(t) { return t != null; });
    }

    public static function getExercisesTasksByUser(user: User): List<CodeforcesTask> {
        var trainingIds = Lambda.array(Lambda.map(Training.manager.search($userId == user.id), function(t) { return t.id; }));
        var taskIds = Lambda.map(Exercise.manager.search($trainingId in trainingIds), function(t){ return t.task; });
        return Lambda.list(taskIds);
    }

    public static function getTaskIdsByTags(tagIds: Array<Float>): StringMap<Bool> {
        var res = new StringMap<Bool>();
        var relations = CodeforcesTaskTag.manager.search($tagId in tagIds);
        for (r in relations) {
            if (r.task.active)
                res.set(Std.string(r.task.id), true);
        }
        return res;
    }

    public static function getTasksForUser(user: User, minLevel: Int, maxLevel: Int, tagIds: Array<Float>, taskIds: Array<Float>, length: Int): Array<CodeforcesTask> {
        var solvedTaskIds: List<Float> = Lambda.map(getTasksSolvedByUser(user), function(t) { return t.id; });
        var exercisesTaskIds: List<Float> = Lambda.map(getExercisesTasksByUser(user), function(t) { return t.id; });
        var taskIdsByTags = getTaskIdsByTags(tagIds);

        var tasks: Array<CodeforcesTask> =
                Lambda.array(
                    Lambda.filter(
                        CodeforcesTask.manager.search(
                            $active == true &&
                            $level >= minLevel &&
                            $level <= maxLevel &&
                            !($id in solvedTaskIds) &&
                            !($id in exercisesTaskIds) &&
                            if (taskIds != null && taskIds.length > 0) ($id in taskIds) else true),
                        function(t) { return  taskIdsByTags.exists(Std.string(t.id)); }));
        var res = [];
        if (tasks.length > length){
            for (i in 0...length) {
                res.push(getRandomItemAndRemoveItFromList(tasks));
            }
            return res;
        }else if(tasks.length == 0) return null;
        else return tasks;
    }

    private static function getRandomItemAndRemoveItFromList<T>(a: Array<T>): T {
        var i = Math.round(Math.random() * (a.length - 1));
        var res = a[i];
        a.remove(res);
        return res;
    }

    public static function createTrainingsByMetaTrainingsForGroup(groupId: Float): Bool {
        var assignments: List<Assignment> = Assignment.manager.search($groupId == groupId);
        var learners: Array<User> =
        Lambda.array(
            Lambda.map(
                GroupLearner.manager.search($groupId == groupId),
                function(gl) { return gl.learner; }));

        for (l in learners) {
            if (!createTrainingsByMetaTrainingsForAssignmentsAndLearner(assignments, l)) return false;
        }

        return true;
    }

    public static function createTrainingsByMetaTrainingsForAssignmentsAndLearner(assignments: List<Assignment>, learner: User): Bool {
        for (a in assignments) {
            if (a.learnerIds == null || Lambda.has(a.learnerIds, learner.id) ){
                var t: Training = Training.manager.select($userId == learner.id && $assignmentId == a.id);
                if (t == null) {
                    t = new Training();
                    t.assignment = a;
                    t.user = learner;
                    t.insert();

                    var tasks = ModelUtils.getTasksForUser(
                        learner,
                        a.metaTraining.minLevel,
                        a.metaTraining.maxLevel,
                        a.metaTraining.tagIds,
                        a.metaTraining.taskIds,
                        if (a.metaTraining.length != null) a.metaTraining.length else 5);

                    if (null == tasks) {
                        return false;
                    } else {
                        for (task in tasks) {
                            var exercise = new Exercise();
                            exercise.task = task;
                            exercise.training = t;
                            exercise.insert();
                        }
                    }
                }
            }
        }
        return true;
    }
}
