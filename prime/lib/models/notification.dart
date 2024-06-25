class Notification {
  String? id;
  String? userId;
  String? title;
  String? body;
  String? linkedObjectId;
  String? linkedObjectType;
  bool? isRead;
  DateTime? createdAt;

  Notification({
    this.id,
    this.userId,
    this.title,
    this.body,
    this.linkedObjectId,
    this.linkedObjectType,
    this.isRead,
    this.createdAt,
  });
  factory Notification.fromMap(String id, Map<String, dynamic> map) {
    return Notification(
      id: id,
      userId: map['userId'],
      title: map['title'],
      body: map['body'],
      linkedObjectId: map['linkedObjectId'],
      linkedObjectType: map['linkedObjectType'],
      isRead: map['isRead'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['createdAt'].millisecondsSinceEpoch)
          : null,
    );
  }
}
// create enum for linkedObjectType
// create fromMap method