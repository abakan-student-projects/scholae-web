package service;

import notification.NotificationStatus;
import utils.StringUtils;
import model.User;
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

    private function sendNotificationToEmail(notification: Notification) {
        JobQueue.publishScholaeJob(
            ScholaeJob.SendNotificationToEmail(notification.id),
            Authorization.instance.session.id
        );
        /*haxe.Timer.delay(
            function(){

                trace("finish timer sending to email after 1 min");
            }, notification.delayBetweenSending * 1000
        );*/
    }

    public function sendEmail(notificationId: Float): Bool {
        var notification: Notification = Notification.manager.get(notificationId);
        var user: User = User.manager.get(notification.user.id);
        var subjectForUser ='Scholae: notification';
        var password = StringUtils.getRandomString(StringUtils.alphaNumeric, 8);
        //todo affirm email's templates
        //var template = new haxe.Template(haxe.Resource.getString("renewPasswordEmail"));
        var message = notification.message;
        var from = 'From: no-reply@scholae.lambda-calculus.ru';
        //todo uncomment sending email
        //var email = mail(user.email, subjectForUser, message, from);
        var email = true;
        trace(message);
        if (email == true) {
            notification.status = NotificationStatus.Completed;
            notification.update();
            return true;
        } else {
            notification.status = NotificationStatus.InProgress;
            notification.update();
            return false;
        }
    }
}
