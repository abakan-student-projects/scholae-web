package service;

import model.User;
import model.Group;
import model.Role;
import messages.ResponseStatus;
import messages.ResponseMessage;

class ServiceHelper {
    public static function authorize(role: Role, next: Void -> ResponseMessage): ResponseMessage {
        if (!Authorization.instance.authorize(Role.Teacher)) {
            return { status: ResponseStatus.Error, result: null, message: "Not authorized" };
        } else {
            return next();
        }
    }

    public static function authorizeGroup(group: Group, teacher: User, next: Void -> ResponseMessage): ResponseMessage {
        if (group.teacher.id != teacher.id) {
            return { status: ResponseStatus.Error, result: null, message: "Not authorized" };
        } else {
            return next();
        }
    }

    public static function successResponse(result: Dynamic): ResponseMessage {
        return { status: ResponseStatus.OK, result: result };
    }
}
