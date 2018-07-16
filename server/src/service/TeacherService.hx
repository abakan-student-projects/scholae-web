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
}
