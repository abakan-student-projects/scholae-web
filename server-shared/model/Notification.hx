package model;

import haxe.EnumTools.EnumValueTools;
import haxe.EnumTools.EnumValueTools;
import sys.db.Types.SEnum;
import notification.NotificationType;
import sys.db.Types.SBigId;
import notification.NotificationStatus;
import model.User;
import sys.db.Types.SDateTime;
import sys.db.Types.SInt;
import notification.NotificationMessage;
import notification.NotificationDestination;
import sys.db.Manager;
import sys.db.Types.SString;

@:table("Notification")
class Notification extends sys.db.Object {
    public var id: SBigId;
    @:relation(userId) public var user : User;
    public var message: SString<512>;
    public var link: SString<512>;
    public var type: SEnum<NotificationType>;
    public var status: SEnum<NotificationStatus>;
    public var date: SDateTime;
    public var primaryDestination: SEnum<NotificationDestination>;
    public var delayBetweenSending: SInt;
    public var secondaryDestination: SEnum<NotificationDestination>;

    public function new() {
        super();
    }

    public static var manager = new Manager<Notification>(Notification);

    public static function getNotificationsByUserForClient(user: User): List<Notification> {
        var notifications: List<Notification> = manager.search(
            $userId == user.id &&
            $status == NotificationStatus.New &&
            $primaryDestination == NotificationDestination.client
        );
        trace("Length - " + notifications.length);
        var s = if (notifications.length > 0) notifications else null;
        return s;
    }

    public static function getNotificationsByUserForEmail(user: User): List<Notification> {
        var notifications = manager.search(
            $userId == user.id &&
            $status == NotificationStatus.New &&
            $primaryDestination == NotificationDestination.mail
        );
        var s = if (notifications.length > 0) notifications else null;
        return s;
    }

    public function toNotificationMessage():NotificationMessage {
        return
            {
                id: id,
                message: message,
                link: link,
                type: EnumValueTools.getName(type)
            }
    }
}
