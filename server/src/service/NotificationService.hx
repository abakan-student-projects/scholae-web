package service;

import notification.NotificationStatus;
import jobs.ScholaeJob;
import jobs.JobQueue;
import model.Notification;
import messages.ResponseMessage;

class NotificationService {

    public function new() {
    }

    public function getNotifications(): ResponseMessage {
        if(Authorization.instance.currentUser != null) {
            var notifications: List<Notification> =
                Notification.getNotificationsByUserForClient(Authorization.instance.currentUser);
            if(notifications != null) {
                return ServiceHelper.successResponse(
                    Lambda.array(
                        Lambda.map(
                        notifications,
                        function(t: Notification) {
                            if (t.secondaryDestination == null) {
                                t.status = NotificationStatus.Completed;
                            } else {
                                t.status = NotificationStatus.InProgress;
                            }
                            t.update();
                            return t.toNotificationMessage();
                        })));
            } else {
                return ServiceHelper.failResponse("No notifications");
            }
        } else {
            return ServiceHelper.failResponse("Not autorized");
        }
    }

    public function sendNotificationToEmail(notification: Notification) {
        notification.status = NotificationStatus.InProgress;
        notification.update();
        JobQueue.publishScholaeJob(
            ScholaeJob.SendNotificationToEmail(notification.id),
            Authorization.instance.session.id
        );
    }
}
