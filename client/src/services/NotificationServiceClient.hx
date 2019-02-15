package services;

import utils.UIkit;
import notification.NotificationMessage;
import js.Promise;

class NotificationServiceClient extends BaseServiceClient {

    private static var _instance: NotificationServiceClient;
    public static var instance(get, null): NotificationServiceClient;
    private static function get_instance(): NotificationServiceClient {
        if (null == _instance) _instance = new NotificationServiceClient();
        return _instance;
    }

    public var isWorking: Bool;

    public function new() {
        super();
        isWorking = false;
    }

    public function start() {
        if(!isWorking) {
            isWorking = true;
            getNotifications();
        }
    }

    public function stop() {
        isWorking = false;
    }

    public function getNotifications(): Void {
        trace("isWorking = " + isWorking);
        if(isWorking) {
            trace("start getting notification");
            var requestNotification = request(function(success, fail) {
                context.NotificationService.getNotifications.call([], function(e) {
                    processResponse(e, success, fail);
                });
            });
            requestNotification.then(
                function(notifications) {
                    trace("go send notify");
                    sendNotification(notifications);
                    planServerRequestOrStop();
                },
                function(e) {
                    trace("error while get notification - " + e);
                    planServerRequestOrStop();
                });
        }
    }

    private function sendNotification(notifications: Array<NotificationMessage>) {
        if(notifications != null) {
            for (notification in notifications) {
                if(notification.link != null)
                    notification.message =
                        "<a class=\"uk-link-reset\" href=\""+notification.link+"\" target=\"_blank\">"+notification.message+"</a>";
                UIkit.notification({
                    message: notification.message,
                    status: notification.type,
                    timeout: 10000,
                    pos: 'bottom-right' });
            }
        }
    }
    private function planServerRequestOrStop(): Void {
        haxe.Timer.delay(getNotifications, 30000);
    }
}
