package service;

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
}
