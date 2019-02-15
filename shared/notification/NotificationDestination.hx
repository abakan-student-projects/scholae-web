package notification;

@:enum
abstract NotificationDestination(String) {
    var Client = "Client";
    var Mail = "Mail";
    var Push = "Push";
    var ClientAndMail = "ClientAndMail";
    var ClientAndPush = "ClientAndPush";
}
