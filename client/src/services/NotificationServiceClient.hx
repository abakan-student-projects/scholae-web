package services;

import notification.NotificationType;
import utils.UIkit;
import notification.NotificationMessage;

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
        if(isWorking) {
            var requestNotification = request(function(success, fail) {
                context.NotificationService.getNotifications.call([], function(e) {
                    processResponse(e, success, fail);
                });
            });
            requestNotification.then(
                function(notifications: Array<NotificationMessage>) {
                    sendNotification(notifications);
                    planServerRequestOrStop();
                },
                function(e) {
                    planServerRequestOrStop();
                });
        }
    }

    private inline function sendNotification(notifications: Array<NotificationMessage>) {
        if(notifications != null) {
            for (n in notifications) {
                var notification: NotificationType = haxe.Unserializer.run(n.type);
                switch(notification) {
                    case SimpleMessage(message, type): {
                        var template = new haxe.Template(haxe.Resource.getString("simpleNotification"));
                        var notificationMessage = template.execute({message: message});
                        showNotification(notificationMessage, type);
                    }
                    case MessageWithLink(message, link, type) :{
                        var template = new haxe.Template(haxe.Resource.getString("notificationWithLink"));
                        var notificationMessage = template.execute({message: message, link: link});
                        showNotification(notificationMessage, type);
                    }
                    default: null;
                };
            }
        }
    }

    private inline function showNotification(message: String, status: String) {
        UIkit.notification({
            message: message,
            status: status,
            timeout: 5000,
            pos: 'bottom-right' });
    }

    private inline function planServerRequestOrStop(): Void {
        haxe.Timer.delay(getNotifications, 15000);
    }
}
