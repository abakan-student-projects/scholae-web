package service;

import Lambda;
import Array;
import haxe.ds.ArraySort;
import model.CodeforcesTaskTag;
import messages.RatingMessage.RatingCategory;
import jobs.ScholaeJob;
import jobs.JobQueue;
import model.LinksForTags;
import model.CodeforcesTask;
import model.ModelUtils;
import messages.MetaTrainingMessage;
import messages.AttemptMessage;
import utils.IterableUtils;
import messages.ExerciseMessage;
import model.Attempt;
import codeforces.Codeforces;
import messages.TrainingMessage;
import model.Exercise;
import model.ModelUtils;
import model.Training;
import model.MetaTraining;
import model.Assignment;
import messages.AssignmentMessage;
import model.CodeforcesTag;
import model.GroupLearner;
import messages.ResponseStatus;
import messages.ResponseMessage;
import model.Role;
import model.Group;
import messages.GroupMessage;
import messages.SessionMessage;
import model.Session;
import model.User;

typedef CategoryWeight = {
    category: Float,
    level: Int,
    weight: Float
}

class TeacherService {

    public function new() {}

    public function getAllGroups(): ResponseMessage {
        return ServiceHelper.authorize(Role.Teacher, function() {
            return ServiceHelper.successResponse(
                Lambda.array(
                    Lambda.map(
                        Group.getGroupsByTeacher(Authorization.instance.currentUser),
                        function(g) {
                            return {
                                id: g.id,
                                name: g.name,
                                signUpKey: g.signUpKey
                            }
                        }))
            );
        });
    }

    public function getAllLearnersByGroup(groupId: Float): ResponseMessage {
        return ServiceHelper.authorize(Role.Teacher, function() {
            return ServiceHelper.authorizeGroup(Group.manager.get(groupId), Authorization.instance.currentUser, function() {
                return ServiceHelper.successResponse(
                    Lambda.array(
                        Lambda.map(
                            GroupLearner.manager.search($groupId == groupId),
                            function(gl) { return gl.learner.toLearnerMessage(); }))
                );
            });

        });
    }

    public function getAllRating(groupId: Float) : ResponseMessage {
        return ServiceHelper.authorize(Role.Teacher, function() {
            var learners = Lambda.array(Lambda.map(GroupLearner.manager.search($groupId == groupId), function(gl) { return gl.learner.id; }));
            var user = User.manager.search($id in learners);
            return ServiceHelper.successResponse(
                Lambda.array(
                    Lambda.map(user, function(u) { return u.toRatingMessage(u.id); })));
        });
    }

    public function getRatingsForUsers(userIds: Array<Float>, startDate: Date, finishDate: Date) : ResponseMessage {
        return ServiceHelper.authorize(Role.Teacher, function() {
            var user = User.manager.search($id in userIds);
            return ServiceHelper.successResponse(
                Lambda.array(
                    Lambda.map(user, function(u) {return u.toRatingMessage(u.id, startDate, finishDate);})));
        });
    }

    public function addGroup(name: String, signUpKey: String): ResponseMessage {
        return ServiceHelper.authorize(Role.Teacher, function() {
            var g = new Group();
            g.name = name;
            g.signUpKey = signUpKey;
            g.teacher = Authorization.instance.currentUser;
            g.insert();
            return ServiceHelper.successResponse(g.toMessage());
        });
    }

    // The method's also used by learners
    public function getAllTags(): ResponseMessage {
        return ServiceHelper.successResponse(
            Lambda.array(
                Lambda.map(
                    CodeforcesTag.manager.all(),
                    function(t) { return t.toMessage(); }))
        );
    }

    public function getAllLinks(): ResponseMessage {
        return ServiceHelper.successResponse(
            Lambda.array(
                Lambda.map(
                    LinksForTags.manager.all(),
                    function(l) { return l.toMessage(); })));
    }

    public function createAssignment(group: GroupMessage, assignment: AssignmentMessage): ResponseMessage {
        return ServiceHelper.authorize(Role.Teacher, function() {
            return ServiceHelper.authorizeGroup(Group.manager.get(group.id), Authorization.instance.currentUser, function() {
                var m = new MetaTraining();
                m.minLevel = assignment.metaTraining.minLevel;
                m.maxLevel = assignment.metaTraining.maxLevel;
                m.tagIds = assignment.metaTraining.tagIds;
                m.taskIds = assignment.metaTraining.taskIds;
                m.length = assignment.metaTraining.length;
                m.insert();

                var a = new Assignment();
                a.name = assignment.name;
                a.startDateTime = assignment.startDate;
                a.finishDateTime = assignment.finishDate;
                a.learnerIds = assignment.learnerIds;
                a.metaTraining = m;
                a.group = Group.manager.get(group.id);
                a.insert();

                ModelUtils.createTrainingsByMetaTrainingsForGroup(group.id);

                return ServiceHelper.successResponse(a.toMessage());
            });
        });
    }

    public function createAdaptiveAssignment(group: GroupMessage, name: String, startDate: Date, finishDate: Date, tasksCount: Int, learnerIds: Array<Float>): ResponseMessage {
        return ServiceHelper.authorize(Role.Teacher, function() {
            return ServiceHelper.authorizeGroup(Group.manager.get(group.id), Authorization.instance.currentUser, function() {
                var tagIds = [];
                var taskIds = [];
                var tasks = [];
                for (l in learnerIds) {
                    tasks = getTasksIds(l,tasksCount,null);
                    for (t in tasks) {
                        taskIds.push(t);
                    }
                }
                var taskTag = CodeforcesTaskTag.manager.search($taskId in taskIds);
                tagIds = [for (t in taskTag) t.tag.id];

                var m = new MetaTraining();
                m.minLevel = null;
                m.maxLevel = null;
                m.tagIds = tagIds;
                m.taskIds = taskIds;
                m.length = tasksCount;
                m.insert();

                var a = new Assignment();
                a.name = name;
                a.startDateTime = startDate;
                a.finishDateTime = finishDate;
                a.learnerIds = learnerIds;
                a.metaTraining = m;
                a.group = Group.manager.get(group.id);
                a.insert();

                var assignments: List<Assignment> = Assignment.manager.search($groupId == group.id && $deleted != true);
                for (l in learnerIds) {
                    for (a in assignments) {
                        var user = User.manager.select($id == l);
                        var t: Training = Training.manager.select($userId == l && $assignmentId == a.id && $deleted != true);
                        if (t == null) {
                            t = new Training();
                            t.assignment = a;
                            t.user = user;
                            t.insert();

                            var exercisesTaskIds: List<Float> = Lambda.map(ModelUtils.getExercisesTasksByUser(user), function(t) {return t.id; });
                            var taskIds = getTasksIds(l, tasksCount, exercisesTaskIds);
                            var tasks = CodeforcesTask.manager.search($id in taskIds);
                            if (tasks != null)  {
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

                return ServiceHelper.successResponse(a.toMessage());
            });
        });
    }

    public function getTasksIds(learnerId: Float, tasksCount: Float, exercisesTaskIds: List<Float>) {
        var resultTasks: Array<CategoryWeight> = [];
        var res = [];
        var currentRatingCategory = [];
        var tags = CodeforcesTag.manager.all();
        var levels = [1,2,3,4,5];
        var weight: Float = 0;
        var forTrace = [];
        var rating:Float = 0;
        var categoryWeight: Array<CategoryWeight> = [];
        currentRatingCategory = getRatingCategory(learnerId);

        for (t in tags) {
            for (c in currentRatingCategory){
                if (t.id == c.id) {
                    for (l in levels) {
                        rating = Math.pow(2,l-1) * (t.importance/tags.length);
                        weight = Math.abs(Math.log(c.rating + 1) - Math.log(c.rating + rating + 1));
                        categoryWeight.push({category: t.id, level: l, weight: Math.round(weight*100)/100});
                    }
                }
            }
        }

        ArraySort.sort(categoryWeight, function(x: CategoryWeight, y: CategoryWeight) { return if (x.weight < y.weight) 1 else -1; });
        var learnerLevel = null;
        var taskIds = [];
        var tasks = [];
        for (c in categoryWeight) {
            learnerLevel = getLearnerLevel(c.category, c.level, learnerId);
            if (learnerLevel == c.level) {
                taskIds = getNotSolvedTaskIds(c.category,learnerLevel,learnerId, exercisesTaskIds);
                tasks.push(taskIds);
            }
        }
        var j = 1;
        var tasksFinished = [];
        for (task in tasks) {
            if (task.length != 0) {
                for(t in task) {
                    if (j <= tasksCount) {
                        tasksFinished.push(t);
                        j++;
                    }
                }
            }
        }
        return tasksFinished;
    }

    public function getLearnerLevel(category: Float, level: Int, learnerId: Float) {
        var tasksTag = CodeforcesTaskTag.manager.search($tagId == category);
        var tasksTagIds = [for (t in tasksTag) if (t.task != null) t.task.id];
        var tasks = CodeforcesTask.manager.search(($id in tasksTagIds) && ($level == level));
        var taskIds = [for (t in tasks) t.id];
        var attempt = Lambda.array(Lambda.map(Attempt.manager.search($userId == learnerId && $solved == true && ($taskId in taskIds)), function(a){return a;}));
        var countSolvedTasks = 0;
        var learnerLevel = 0;
        if (attempt.length != 0) {
            for (a in attempt) {
                for (t in taskIds) {
                    if (a.task != null && t == a.task.id) {

                        countSolvedTasks++;
                        learnerLevel = level;
                    }
                }
            }
        }
        switch(learnerLevel){
            case 1: if (countSolvedTasks >= 3) {
                        learnerLevel = 2;
                    }
            case 2: if (countSolvedTasks >= 10) {
                        learnerLevel = 3;
                    }
            case 3: if (countSolvedTasks >= 20) {
                        learnerLevel = 4;
                    }
            case 4: if (countSolvedTasks >= 50) {
                        learnerLevel = 5;
                    }
            case 5: learnerLevel = 5;
            default : learnerLevel = 1;
        }

        return learnerLevel;
    }

    public function getNotSolvedTaskIds(category: Float, level: Int, learnerId: Float, exercisesTasksIds: List<Float>) {
        var user: User = User.manager.select($id == learnerId);
        var solvedTasks = ModelUtils.getTasksSolvedByUser(user);
        var solvedTasksIds = [for (s in solvedTasks) s.id];
        var tasksTag = CodeforcesTaskTag.manager.search($tagId == category);
        var tasksTagIds = [for (t in tasksTag) if (t.task != null) t.task.id];
        var tasks = CodeforcesTask.manager.search(($id in tasksTagIds) && ($level == level) && !($id in solvedTasksIds) && !($id in exercisesTasksIds));
        var notSolvedTasks = [for (t in tasks) t.id];
        return notSolvedTasks;
    }

    public function getRatingCategory(userId: Float) {
        var rating = 0;
        var res: Array<RatingCategory> = [];
        var attempts = Attempt.manager.search(($userId == userId) && ($solved == true));
        var tagIds = CodeforcesTag.manager.all();
        var taskIds = [for (a in attempts) a.task.id];
        var taskTagIds = CodeforcesTaskTag.manager.search($taskId in taskIds);
        var ratingLearnerCategoryTask: Float = 0;
        for (t in tagIds) {
            for (taskTag in taskTagIds) {
                if (taskTag.tag.id == t.id) {
                    ratingLearnerCategoryTask += Math.pow(2, taskTag.task.level-1) * (taskTag.tag.importance/tagIds.length);
                }
            }
            if (ratingLearnerCategoryTask != 0) {
                res.push({id: t.id, rating: Math.round((ratingLearnerCategoryTask+1)*100)/100});
                ratingLearnerCategoryTask = 0;
            } else {
                res.push({id:t.id, rating: 0});
            }
        }
        return res;
    }


    public function getAssignmentsByGroup(groupId: Float): ResponseMessage {
        return ServiceHelper.authorize(Role.Teacher, function() {
            return ServiceHelper.authorizeGroup(Group.manager.get(groupId), Authorization.instance.currentUser, function() {
                return ServiceHelper.successResponse(
                    Lambda.array(
                        Lambda.map(
                            Assignment.manager.search($groupId == groupId && $deleted != true),
                            function(a) { return a.toMessage(); }))
                );
            });

        });
    }

    public function createTrainingsByMetaTrainings(groupId: Float): ResponseMessage {
        return ServiceHelper.authorize(Role.Teacher, function() {
            return ServiceHelper.authorizeGroup(Group.manager.get(groupId), Authorization.instance.currentUser, function() {
                return
                    if (ModelUtils.createTrainingsByMetaTrainingsForGroup(groupId))
                        getAssignmentsByGroup(groupId)
                    else
                        ServiceHelper.failResponse('Недостаточно задач в базе');
            });

        });
    }

    public function getTrainingsByGroup(groupId: Float): ResponseMessage {
        return ServiceHelper.authorize(Role.Teacher, function() {
            return ServiceHelper.authorizeGroup(Group.manager.get(groupId), Authorization.instance.currentUser, function() {
                return ServiceHelper.successResponse(
                    Lambda.array(
                        Lambda.map(
                            Training.getTrainingsByGroup(groupId),
                            function(t) { return t.toMessage(); })));
            });
        });
    }

    public function refreshResultsForGroup(groupId: Float): ResponseMessage {
        return ServiceHelper.authorize(Role.Teacher, function() {
            return ServiceHelper.successResponse(
                    JobQueue.publishScholaeJob(ScholaeJob.RefreshResultsForGroup(groupId), Authorization.instance.session.id));
        });
    }

    public function getLastAttemptsForTeacher(length: Int): ResponseMessage {
        return ServiceHelper.authorize(Role.Teacher, function() {

            var exercises = Exercise.getAllExercisesForTeacher(Authorization.instance.currentUser);
            var exercisesMap = IterableUtils.createStringMapOfArrays2(
                    exercises,
                    function(e) { return Std.string(e.task.id); },
                    function(e) { return Std.string(e.training.user.id); });
            var attempts = Attempt.getLastAttemptsForExercises(exercises, length);

            var res = [];
            for (a in attempts) {
                var usersMap = exercisesMap.get(Std.string(a.task.id));
                if (null != usersMap) {
                    var userTaskExercises = usersMap.get(Std.string(a.user.id));
                    if (null != userTaskExercises) for (e in userTaskExercises) {
                        var message: AttemptMessage = a.toMessage();
                        message.trainingId = e.training.id;
                        message.assignmentId = e.training.assignment.id;
                        message.groupId = e.training.assignment.group.id;
                        res.push(message);
                    }
                }
            }
            return ServiceHelper.successResponse(res.slice(0, length));
        });
    }

    public function getAllTasksByMetaTraining(metaTraining: MetaTrainingMessage, filter: String): ResponseMessage {
        var taskIdsByTags = [];
        for (t in ModelUtils.getTaskIdsByTags(metaTraining.tagIds).keys()) {
            taskIdsByTags.push(Std.parseFloat(t));
        }
        var tasks;
        if (filter == null){
            tasks = Lambda.array(
                Lambda.map(
                    CodeforcesTask.manager.search($active == true && $level >= metaTraining.minLevel && $level <= metaTraining.maxLevel && ($id in taskIdsByTags)),
                function(t) { return t.toMessage(); }
        )
            );} else {
            tasks= Lambda.array(
                Lambda.map(
                    CodeforcesTask.manager.search($active == true && $level >= metaTraining.minLevel && $level <= metaTraining.maxLevel && ($id in taskIdsByTags) && ($name.like("%"+filter+"%"))),
                function(t) { return t.toMessage(); }
            )
            );
        }

        return ServiceHelper.successResponse(
            {
                offset: 0,
                totalLength: tasks.length,
                data: tasks.slice(0, 10)
            }
        );
    }

    public function deleteLearner(learnerId: Float, groupId: Float) : ResponseMessage {
        return ServiceHelper.authorize(Role.Teacher, function() {
            var assignment = Assignment.manager.search($groupId == groupId);
            var assignmentIds = [];
            for (a in assignment) {
                if (null != a.learnerIds) {
                    for (l in a.learnerIds){
                        if (l == learnerId){
                            assignmentIds.push(a.id);
                        }
                    }
                }
            }
            var assign = Assignment.manager.search($id in assignmentIds);
            for (a in assign) {
                var learnerIds = [];
                for (id in a.learnerIds) {
                    if (id != learnerId){
                        learnerIds.push(id);
                    }
                }
                a.learnerIds = learnerIds;
                a.update();
            }
            var user = User.manager.select($id == learnerId);
            var training = Training.manager.search($userId == user.id && $assignmentId in assignmentIds);
            var trainingIds = [for (t in training) t.id];
            Training.manager.delete($id in trainingIds);
            Exercise.manager.delete($trainingId in trainingIds);
            GroupLearner.manager.delete($groupId == groupId && $learnerId == learnerId);

            return ServiceHelper.successResponse(learnerId);
        });
    }

    public function deleteCourse(groupId: Float): ResponseMessage {
        return ServiceHelper.authorize(Role.Teacher, function() {
            var group = Group.manager.select($id == groupId);
            group.deleted = true;
            group.update();
            var assignments = Assignment.manager.search($groupId == groupId);
            var assignmentIds = [for (a in assignments) a.id];
            for (a in assignments) {
                a.deleted = true;
                a.update();
            }
            var trainings = Training.manager.search($assignmentId in assignmentIds);
            var trainingIds = [ for (t in trainings) t.id];
            for (t in trainings) {
                t.deleted = true;
                t.update();
            }
            var exercises = Exercise.manager.search($trainingId in trainingIds);
            for (e in exercises) {
                e.deleted = true;
                e.update();
            }

            return ServiceHelper.successResponse(groupId);
        });
    }
}
