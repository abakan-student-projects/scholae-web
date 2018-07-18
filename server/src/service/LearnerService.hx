package service;

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
                return ServiceHelper.successResponse(group.toMessage());
            } else {
                return ServiceHelper.failResponse("Введенный ключ не найден.");
            }
        });
    }
}
