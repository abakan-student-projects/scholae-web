package model;

import notification.NotificationStatus;
import model.User;
import sys.db.Types.SDateTime;
import sys.db.Types.SInt;
import notification.NotificationMessage;
import notification.NotificationDestination;
import sys.db.Manager;
import sys.db.Types.SString;
import sys.db.Types.SBigId;

@:table("Notification")
class Notification extends sys.db.Object {
    public var id: SBigId;
    @:relation(userId) public var user : User;
    public var message: SString<512>;
    public var link: SString<512>;
    public var type: SString<128>;
    public var status: SString<128>;
    public var date: SDateTime;
    public var primaryDestination: SString<128>;
    public var delayBetweenSending: SInt;
    public var secondaryDestination: SString<128>;

    public function new() {
        super();
    }

    public static var manager = new Manager<Notification>(Notification);

    public static function getNotificationsByUserForClient(user: User): List<Notification> {
        var notifications = manager.search($userId == user.id && $primaryDestination == NotificationDestination.client);
        var s = if (notifications.length > 0) notifications else null;
        return s;
    }

    public static function getNotificationsByUserForEmail(user: User): List<Notification> {
        var notifications = manager.search({
            userId : user.id,
            status: NotificationStatus.New,
            primaryDestination: NotificationDestination.mail
        }, true);
        var s = if (notifications.length > 0) notifications else null;
        return s;
    }

    public function toNotificationMessage():NotificationMessage {
        return
            {
                id: id,
                message: message,
                link: link,
                type: type
            }
    }
}
