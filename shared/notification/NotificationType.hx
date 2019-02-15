package notification;

@:enum
abstract NotificationType(String) {
    var Primary = "Primary";
    var Success = "Success";
    var Warning = "Warning";
    var Danger = "Danger";
}
