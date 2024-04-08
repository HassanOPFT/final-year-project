class VerificationDocument {
  String? id;
  String? linkedObjectId;
  String? linkedObjectType;
  String? documentUrl;
  String? documentType;
  String? status;
  DateTime? expiryDate;
  String? referenceNumber;
  DateTime? createdAt;

  VerificationDocument({
    this.id,
    this.linkedObjectId,
    this.linkedObjectType,
    this.documentUrl,
    this.documentType,
    this.status,
    this.expiryDate,
    this.referenceNumber,
    this.createdAt,
  });
}
