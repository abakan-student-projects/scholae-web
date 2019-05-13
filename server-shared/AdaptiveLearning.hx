package ;

import utils.IterableUtils;
import Array;
import messages.RatingMessage.RatingCategory;
import haxe.ds.ArraySort;
import haxe.ds.StringMap;
import model.CodeforcesTag;
import model.CodeforcesTaskTag;
import model.CodeforcesTask;

typedef CategoryLevel = {
    category: CodeforcesTag,
    level: Int
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
        var testingTasks = new StringMap<CodeforcesTask>();
        var result: Array<CodeforcesTask> = [];
        for (c in categoryLevels) {
            for (t in tasks) {
                if (t.task != null) {
                    if ((c.category.id == t.tag.id) && (t.task.level == c.level)) {
                        possibleTaskTag.push(t);
                    }
                }
            }
        }
        ArraySort.sort(possibleTaskTag, function(x: CodeforcesTaskTag, y: CodeforcesTaskTag) (return if(x.tag.importance < y.tag.importance) 1 else -1));
        for (p in possibleTaskTag) {
            testingTasks.set(Std.string(p.task.id), p.task);
        }
        result = [for (t in testingTasks) t];
        return result;
    }

    public static function calcLearnerLevel(solvedTaskTag: Array<CodeforcesTaskTag>, tags: Array<CodeforcesTag>): Array<CategoryLevel> {
        var result: Array<CategoryLevel> = [];
        var tagLevel = new StringMap<Int>();
        var countSolved = 1;
        for (t in tags) {
            if (solvedTaskTag != null) {
                for (s in solvedTaskTag) {
                    if (t.id == s.tag.id) {
                        if (countSolved > 0 && countSolved < 3){
                            tagLevel.set(Std.string(t.id), 1);
                        } else if(countSolved >= 3 && countSolved < 10) {
                            tagLevel.set(Std.string(t.id), 2);
                        } else if (countSolved >= 10 && countSolved < 20) {
                            tagLevel.set(Std.string(t.id), 3);
                        } else if (countSolved >= 20 && countSolved < 50) {
                            tagLevel.set(Std.string(t.id), 4);
                        } else if (countSolved >= 50) {
                            tagLevel.set(Std.string(t.id), 5);
                        }
                        countSolved++;
                    }
                }
            }
            countSolved = 1;
        }
        for (t in tags) {
            if (tagLevel.exists(Std.string(t.id))) {
                result.push({category:t,level: tagLevel.get(Std.string(t.id))});
            } else {
                result.push({category:t, level: 1});
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
        var resRating: Float = 0;
        var nextRating: Array<RatingCategory> = [];
        var categoryRating = IterableUtils.createStringMap(currentRating, function(c){return Std.string(c.id);});
        var tasksTags2 = IterableUtils.createStringMapOfArrays(possibleTaskTag, function(p){return Std.string(p.task.id);});
        var taskTag: Array<CodeforcesTaskTag> = [];
        var realRating: RatingCategory = null;
        for (t in tasks) {
            taskTag = tasksTags2.get(Std.string(t.id));
            for (tag in taskTag) {
                realRating = categoryRating.get(Std.string(tag.tag.id));
                rating += Math.round(Math.log(Math.pow(2,t.level-1)*(tag.tag.importance/43)+1)*100)/100 + realRating.rating;
            }
            ratingTasks.push({task:t, rating: rating});
            rating = 0;
        }
        ArraySort.sort(ratingTasks, function(x: TaskRating, y: TaskRating){return if (x.rating < y.rating)1 else -1;});
        var result: TaskRating = ratingTasks.shift();
        return result.task;
    }

    public static function emulateSolution(currentRating: Array<RatingCategory>, task: CodeforcesTask, taskTag: Array<CodeforcesTaskTag>): Array<RatingCategory> {
        var result: Array<RatingCategory> = [];
        var rating: Float = 0;
        var categoryRating = new StringMap<Float>();
        var taskTagForTask: Array<CodeforcesTag> = [];
        for (t in taskTag) {
            if (t.task.id == task.id) {
                taskTagForTask.push(t.tag);
            }
        }
        for (c in currentRating) {
            for (t in taskTag) {
                if (t.task != null && t.task.id == task.id) {
                    if (c.id == t.tag.id) {
                        rating = Math.pow(2, task.level-1)*(t.tag.importance/43);
                        rating = Math.round(Math.log(rating+1)*100)/100 + c.rating;
                        categoryRating.set(Std.string(c.id),rating);
                    } else {
                        rating = c.rating;
                    }
                }
            }
            if (!categoryRating.exists(Std.string(c.id))){
                categoryRating.set(Std.string(c.id), rating);
            }
            rating = 0;
        }
        for (c in currentRating) {
            result.push({id:c.id,rating: categoryRating.get(Std.string(c.id))});
        }
        return result;
    }
}
