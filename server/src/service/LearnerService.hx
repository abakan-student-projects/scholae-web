package service;

import jobs.ScholaeJob;
import jobs.JobQueue;
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

    public function getTrainingResults(): ResponseMessage {
        return ServiceHelper.authorize(Role.Learner, function() {
            return ServiceHelper.successResponse(
                JobQueue.publishScholaeJob(ScholaeJob.RefreshResultsForUser(Authorization.instance.currentUser.id), Authorization.instance.session.id));
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
