package service;

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

    public function getAllTags(): ResponseMessage {
        return ServiceHelper.authorize(Role.Teacher, function() {
            return ServiceHelper.successResponse(
                Lambda.array(
                    Lambda.map(
                        CodeforcesTag.manager.all(),
                        function(t) { return t.toMessage(); }))
            );
        });
    }


    public function createAssignment(group: GroupMessage, assignment: AssignmentMessage): ResponseMessage {
        return ServiceHelper.authorize(Role.Teacher, function() {
            return ServiceHelper.authorizeGroup(Group.manager.get(group.id), Authorization.instance.currentUser, function() {
                var m = new MetaTraining();
                m.minLevel = assignment.metaTraining.minLevel;
                m.maxLevel = assignment.metaTraining.maxLevel;
                m.tagIds = assignment.metaTraining.tagIds;
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
                return ServiceHelper.successResponse(a.toMessage());
            });
        });
    }

    public function getAssignmentsByGroup(groupId: Float): ResponseMessage {
        return ServiceHelper.authorize(Role.Teacher, function() {
            return ServiceHelper.authorizeGroup(Group.manager.get(groupId), Authorization.instance.currentUser, function() {
                return ServiceHelper.successResponse(
                    Lambda.array(
                        Lambda.map(
                            Assignment.manager.search($groupId == groupId),
                            function(a) { return a.toMessage(); }))
                );
            });

        });
    }

    public function createTrainingsByMetaTrainings(groupId: Float): ResponseMessage {
        return ServiceHelper.authorize(Role.Teacher, function() {
            return ServiceHelper.authorizeGroup(Group.manager.get(groupId), Authorization.instance.currentUser, function() {

                var assignments: List<Assignment> = Assignment.manager.search($groupId == groupId);
                var learners: Array<User> =
                        Lambda.array(
                            Lambda.map(
                            GroupLearner.manager.search($groupId == groupId),
                            function(gl) { return gl.learner; }));

                for (l in learners) {
                    for (a in assignments) {
                        var t: Training = Training.manager.select($userId == l.id && $assignmentId == a.id);
                        if (t == null) {
                            t = new Training();
                            t.assignment = a;
                            t.user = l;
                            t.insert();

                            var tasks = ModelUtils.getTasksForUser(
                                l,
                                a.metaTraining.minLevel,
                                a.metaTraining.maxLevel,
                                a.metaTraining.tagIds,
                                if (a.metaTraining.length != null) a.metaTraining.length else 5);

                            if (null == tasks) {
                                return ServiceHelper.failResponse('Для пользователя "${l.firstName} ${l.lastName}" недостаточно задач в базе');
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

                return getAssignmentsByGroup(groupId);
            });

        });
    }

    public function getTrainingsByGroup(groupId: Float): ResponseMessage {
        return ServiceHelper.authorize(Role.Teacher, function() {
            return ServiceHelper.authorizeGroup(Group.manager.get(groupId), Authorization.instance.currentUser, function() {
                var assignments: List<Assignment> = Assignment.manager.search($groupId == groupId);
                var trainings: Array<TrainingMessage> = [];

                for (a in assignments) {
                    trainings = trainings.concat(
                            Lambda.array(
                                Lambda.map(
                                    Training.manager.search($assignmentId == a.id),
                                    function(a) { return a.toMessage(); }))
                    );
                }

                return ServiceHelper.successResponse(trainings);
            });
        });
    }
}
