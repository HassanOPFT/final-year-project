class Notification {
  String? id;
  String? userId;
  String? title;
  String? body;
  String? linkedObjectId;
  String? linkedObjectType;
  bool? isRead;
  bool? isDelivered;
  DateTime? createdAt;

  Notification({
    this.id,
    this.userId,
    this.title,
    this.body,
    this.linkedObjectId,
    this.linkedObjectType,
    this.isRead,
    this.isDelivered,
    this.createdAt,
  });
}
// create enum for linkedObjectType