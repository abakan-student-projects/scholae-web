package notification;

@:enum
abstract NotificationStatus(String) {
    var New = "New";
    var InProgress = "InProgress";
    var Completed = "Completed";
}
