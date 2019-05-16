package ;

import Array;
import utils.IterableUtils;
import messages.RatingMessage.RatingCategory;
import haxe.ds.ArraySort;
import haxe.ds.StringMap;
import model.CodeforcesTag;
import model.CodeforcesTaskTag;
import model.CodeforcesTask;

typedef CategoryLevel = {
    category: CodeforcesTag,
    level: Int,
    countSolved: Int
}

typedef TaskRating = {
    task: CodeforcesTask,
    rating: Float
}

class AdaptiveLearning {
    public function new() {
    }

    public static function executeFilter(tasks: Array<CodeforcesTaskTag>, categoryLevels: Array<CategoryLevel>): Array<CodeforcesTask> {
        var possibleTaskTag: Array<CodeforcesTaskTag> = [];
        var lastTasks = new StringMap<CodeforcesTask>();
        var result: Array<CodeforcesTask> = [];
        var tasksTags = IterableUtils.createStringMapOfArrays(tasks, function(t){return if (t.tag != null) Std.string(t.tag.id) else null;});
        var taskTag: Array<CodeforcesTaskTag> = null;
        var i = 0;
        for (c in categoryLevels) {
            taskTag = tasksTags.get(Std.string(c.category.id));
            if (taskTag != null) {
                for (t in taskTag) {
                    if (t.task != null) {
                        i = t.task.level - c.level;
                        if (i == 1) {
                            if (c.level == 1 && c.countSolved >= 3) {
                                possibleTaskTag.push(t);
                            } else if (c.level == 2 && c.countSolved >= 10) {
                                possibleTaskTag.push(t);
                            } else if (c.level == 3 && c.countSolved >= 20) {
                                possibleTaskTag.push(t);
                            } else if (c.level == 4 && c.countSolved >= 50) {
                                possibleTaskTag.push(t);
                            }
                        } else if (i == 0) {
                            possibleTaskTag.push(t);
                        }
                    }
                }
            }
        }
        ArraySort.sort(possibleTaskTag, function(x: CodeforcesTaskTag, y: CodeforcesTaskTag) (return if(x.tag.importance < y.tag.importance) 1 else -1));
        for (p in possibleTaskTag) {
            lastTasks.set(Std.string(p.task.id), p.task);
        }
        result = [for (t in lastTasks) t];
        return result;
    }

    public static function calcLearnerLevel(?solvedTaskTag: Array<CodeforcesTaskTag>, tags: Array<CodeforcesTag>): Array<CategoryLevel> {
        var result: Array<CategoryLevel> = [];
        var countSolved = 1;
        var res = new StringMap<CategoryLevel>();
        for (t in tags) {
            if (solvedTaskTag != null) {
                for (s in solvedTaskTag) {
                    if (t.id == s.tag.id && s.tag != null) {
                        if (s.task != null && s.task.level == 1) {
                            res.set(Std.string(t.id), {category: t, level: 1, countSolved: countSolved});
                        } else if (s.task != null && s.task.level == 2) {
                            res.set(Std.string(t.id), {category: t, level: 2, countSolved: countSolved});
                        } else if (s.task != null && s.task.level == 3) {
                            res.set(Std.string(t.id), {category: t, level: 3, countSolved: countSolved});
                        } else if (s.task != null && s.task.level == 4) {
                            res.set(Std.string(t.id), {category: t, level: 4, countSolved: countSolved});
                        } else if (s.task != null && s.task.level == 5) {
                            res.set(Std.string(t.id), {category: t, level: 5, countSolved: countSolved});
                        }
                        countSolved++;
                    }
                }
            }
            countSolved = 1;
        }
        for (t in tags) {
            if (res.exists(Std.string(t.id))) {
                var calcLevel: CategoryLevel = res.get(Std.string(t.id));
                switch(calcLevel.level) {
                    case 2: if (calcLevel.countSolved >=50) {
                                result.push({category: t, level: 3, countSolved: 0});
                            } else {
                                result.push({category: t, level: 2, countSolved: calcLevel.countSolved});
                            }
                    case 3: if (calcLevel.countSolved >=100) {
                        result.push({category: t, level: 4, countSolved: 0});
                    } else {
                        result.push({category: t, level: 3, countSolved: calcLevel.countSolved});
                    }
                    case 4: if (calcLevel.countSolved >=250) {
                        result.push({category: t, level: 5, countSolved: 0});
                    } else {
                        result.push({category: t, level: 4, countSolved: calcLevel.countSolved});
                    }
                    case 5: result.push({category: t, level: 5, countSolved: calcLevel.countSolved});
                    default : if (calcLevel.countSolved >=15 && calcLevel.level == 1) {
                        result.push({category: t, level: 2, countSolved: 0});
                    } else {
                        result.push({category: t, level: 1, countSolved: calcLevel.countSolved});
                    }
                }
            } else {
                result.push({category:t, level: 1, countSolved: 0});
            }
        }
        return result;
    }

    public static function selectTasks(tasks: Array<CodeforcesTask>, possibleTaskTag: Array<CodeforcesTaskTag>, currentRating: Array<RatingCategory>, tasksCount: Float): Array<CodeforcesTask> {
        var i = 0;
        var task: CodeforcesTask = null;
        var finishedTasks = [];
        while (i < tasksCount) {
            task = nextTask(tasks, currentRating, possibleTaskTag);
            currentRating = emulateSolution(currentRating, task, possibleTaskTag);
            finishedTasks.push(task);
            tasks.remove(task);
            for (p in possibleTaskTag) {
                if (p.task.id == task.id) {
                    possibleTaskTag.remove(p);
                }
            }
            i++;
        }
        return finishedTasks;
    }

    public static function nextTask(tasks: Array<CodeforcesTask>, currentRating: Array<RatingCategory>, possibleTaskTag: Array<CodeforcesTaskTag>): CodeforcesTask {
        var ratingTasks: Array<TaskRating> = [];
        var rating: Float = 0;
        var categoryRating = IterableUtils.createStringMap(currentRating, function(c){return Std.string(c.id);});
        var tasksTags = IterableUtils.createStringMapOfArrays(possibleTaskTag, function(p){return if (p.task != null) Std.string(p.task.id) else null;});
        var taskTag: Array<CodeforcesTaskTag> = [];
        var realRating: RatingCategory = null;
        for (t in tasks) {
            taskTag = tasksTags.get(Std.string(t.id));
            for (tag in taskTag) {
                if (tag.tag != null){
                    realRating = categoryRating.get(Std.string(tag.tag.id));
                    rating += Math.pow(2,t.level-1)*(tag.tag.importance/43) + realRating.rating;
                }
            }
            ratingTasks.push({task:t, rating: Math.round(Math.log(rating+1)*100)/100});
            rating = 0;
        }
        ArraySort.sort(ratingTasks, function(x: TaskRating, y: TaskRating){return if (x.rating < y.rating) 1 else -1;});
        var result: TaskRating = ratingTasks.shift();
        return result.task;
    }

    public static function emulateSolution(currentRating: Array<RatingCategory>, task: CodeforcesTask, taskTag: Array<CodeforcesTaskTag>): Array<RatingCategory> {
        var result: Array<RatingCategory> = [];
        var currentRating = IterableUtils.createStringMap(currentRating, function(c){return Std.string(c.id);});
        var tasksTags = IterableUtils.createStringMapOfArrays(taskTag, function(t){return if (t.task != null) Std.string(t.task.id) else null;});
        var taskTags: Array<CodeforcesTaskTag> = tasksTags.get(Std.string(task.id));
        var rating: Float = 0;
        for (t in taskTags) {
            var curRating: RatingCategory = currentRating.get(Std.string(t.tag.id));
            rating = Math.pow(2,task.level - 1)*(t.tag.importance/43) + curRating.rating;
            currentRating.set(Std.string(curRating.id), {id: curRating.id, rating: rating, name: null});
        }
        result = [for (c in currentRating) c];
        return result;
    }

    public static function selectTasksForChart(tasks: Array<CodeforcesTask>, possibleTaskTags: Array<CodeforcesTaskTag>, currentRating: Array<RatingCategory>, tasksCount: Int, tags: Array<CodeforcesTag>) {
        var learnerLevel = calcLearnerLevel(tags);
        var filteredTasks = executeFilter(possibleTaskTags, learnerLevel);
        var finishedTasks = [];
        var task: CodeforcesTask = null;
        var i = 0;
        var solvedTaskTag: Array<CodeforcesTaskTag> = [];
        while (i < tasksCount) {
            task = nextTask(filteredTasks, currentRating, possibleTaskTags);
            currentRating = emulateSolution(currentRating, task, possibleTaskTags);
            finishedTasks.push(task);
            filteredTasks.remove(task);
            for (p in possibleTaskTags) {
                if (p.task != null && p.tag != null && p.task.id == task.id) {
                    possibleTaskTags.remove(p);
                    solvedTaskTag.push(p);
                }
            }
            learnerLevel = calcLearnerLevel(solvedTaskTag, tags);
            filteredTasks = executeFilter(possibleTaskTags, learnerLevel);
            i++;
        }
        return finishedTasks;
    }
}
