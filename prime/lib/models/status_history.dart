class StatusHistory {
  String? id;
  String? linkedObjectId;
  String? linkedObjectType;
  String? linkedObjectSubtype;
  String? previousStatus;
  String? newStatus;
  String? statusDescription;
  String? modifiedById;
  DateTime? createdAt;

  StatusHistory({
    this.id,
    this.linkedObjectId,
    this.linkedObjectType,
    this.linkedObjectSubtype,
    this.previousStatus,
    this.newStatus,
    this.statusDescription,
    this.modifiedById,
    this.createdAt,
  });
}
