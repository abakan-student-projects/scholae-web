package service;

import notification.NotificationStatus;
import utils.StringUtils;
import model.User;
import notification.NotificationDestination;
import jobs.ScholaeJob;
import jobs.JobQueue;
import notification.Notification;
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
                                t.secondaryDestination == "Mail") {
                                //todo add delay to send email
                                sendNotificationToEmail(t);
                            }
                            return t.toNotificationMessage();
                        })));
        } else {
            return ServiceHelper.failResponse("Not autorized");
        }
    }

    private function sendNotificationToEmail(notification: Notification): Void {
        JobQueue.publishScholaeJob(
            ScholaeJob.SendNotificationToEmail(notification.id),
            Authorization.instance.session.id
        );
    }
}
