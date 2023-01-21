package notification;

enum NotificationType {
   SimpleMessage(message: String, ?style: String);
   MessageWithLink(message: String, link: String, ?style: String);
}
