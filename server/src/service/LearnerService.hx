package service;

import model.ModelUtils;
import model.Assignment;
import model.ModelUtils;
import model.Attempt;
import model.Training;
import model.User;
import messages.GroupMessage;
import messages.ResponseMessage;
import model.Group;
import model.GroupLearner;
import model.Role;

class LearnerService {

    public function new() {}

    public function signUp(key: String): ResponseMessage {
        return ServiceHelper.authorize(Role.Learner, function() {
            var group = Group.getGroupBySignUpKey(key);
            if (null != group) {
                var relation: GroupLearner = GroupLearner.manager.select($groupId == group.id && $learnerId == Authorization.instance.currentUser.id);
                if (null == relation) {
                    relation = new GroupLearner();
                    relation.group = group;
                    relation.learner = Authorization.instance.currentUser;
                    relation.insert();
                }

                var assignments: List<Assignment> = Assignment.manager.search($groupId == group.id);
                ModelUtils.createTrainingsByMetaTrainingsForAssignmentsAndLearner(assignments, Authorization.instance.currentUser);

                return ServiceHelper.successResponse(group.toMessage());
            } else {
                return ServiceHelper.failResponse("Введенный ключ не найден.");
            }
        });
    }

    public function getMyTrainings(): ResponseMessage {
        return ServiceHelper.authorize(Role.Learner, function() {
            return ServiceHelper.successResponse(
                Lambda.array(
                    Lambda.map(
                        Training.manager.search($userId == Authorization.instance.currentUser.id && $deleted != true),
                        function(t) { return t.toMessage(true); })));
            });
    }

    public function refreshResults(): ResponseMessage {
        return ServiceHelper.authorize(Role.Learner, function() {
            Attempt.updateAttemptsForUser(Authorization.instance.currentUser);
            return getMyTrainings();
        });
    }


    public function getRating(learnerId: Float) : ResponseMessage {
        return ServiceHelper.authorize(Role.Learner, function() {
            var user: User;
            if (learnerId == null){
                user = User.manager.select($id == Authorization.instance.currentUser.id);
            } else {
                user = User.manager.select($id == learnerId);
            }
            return ServiceHelper.successResponse(user.toRatingMessage(user.id));
        });
    }

}
