package services;

import js.html.NotificationPermission;
import utils.UIkit;
import notification.NotificationMessage;
import js.html.Notification;
import js.html.Window;

class NotificationServiceClient extends BaseServiceClient {

    private static var _instance: NotificationServiceClient;
    public static var instance(get, null): NotificationServiceClient;
    private static function get_instance(): NotificationServiceClient {
        if (null == _instance) _instance = new NotificationServiceClient();
        return _instance;
    }

    //todo to replace this crutch to more correct code
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
        if(isWorking) {
            var requestNotification = request(function(success, fail) {
                context.NotificationService.getNotifications.call([], function(e) {
                    processResponse(e, success, fail);
                });
            });
            requestNotification.then(
                function(notifications) {
                    sendNotification(notifications);
                    planServerRequestOrStop();
                },
                function(e) {
                    planServerRequestOrStop();
                });
        }
    }

    private function sendNotification(notifications: Array<NotificationMessage>) {
        if(notifications != null) {
            for (notification in notifications) {
                //todo and maybe this crutch
                if (notification.link != null) {
                    notification.message =
                        notification.message + "<br>" +
                        "<button class=\"uk-button uk-width-1-1 uk-margin-small-top\" onClick=\"window.open('" +
                        notification.link + "','_blank')\">Перейти</button>";
                }
                UIkit.notification({
                    message: notification.message,
                    status: notification.type,
                    timeout: 5000,
                    pos: 'bottom-right' });
            }
        }
    }
    private function planServerRequestOrStop(): Void {
        haxe.Timer.delay(getNotifications, 15000);
    }
}
