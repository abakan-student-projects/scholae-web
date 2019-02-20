package service;

import notification.NotificationStatus;
import notification.NotificationDestination;
import jobs.ScholaeJob;
import jobs.JobQueue;
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
                        Notification.getNotificationsByUserForClient(Authorization.instance.currentUser),
                        function(t: Notification) {
                            if (t.secondaryDestination != null &&
                                t.secondaryDestination == NotificationDestination.mail) {
                                sendNotificationToEmail(t);
                            }
                            return t.toNotificationMessage();
                        })));
        } else {
            return ServiceHelper.failResponse("Not autorized");
        }
    }

    private inline function sendNotificationToEmail(notification: Notification) {
        notification.status = NotificationStatus.InProgress;
        notification.update();
        JobQueue.publishScholaeJob(
            ScholaeJob.SendNotificationToEmail(notification.id),
            Authorization.instance.session.id
        );
    }
}
