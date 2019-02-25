package notification;

enum NotificationType {
   SimpleMessage(message: String, ?type: String);
   MessageWithLink(message: String, link: String, ?type: String);
}
