package service;

import model.Notification;
import messages.ResponseMessage;

class NotificationService {

    public function new() {
    }

    public function getNotifications(): ResponseMessage {
        if(Authorization.instance.currentUser != null) {
            return ServiceHelper.successResponse(
                Lambda.array(
                    Lambda.map(
                        Notification.getNotificationsByUser(Authorization.instance.currentUser),
                        function(t) {return t.toNotificationMessage();})));
        } else {
            return ServiceHelper.failResponse("Not autorized");
        }
    }
}
