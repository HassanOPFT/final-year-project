class IssueReport {
  String? id;
  String? referenceNumber;
  String? carRentalId;
  String? reporterId;
  String? reportSubject;
  String? reportDescription;
  String? status;
  DateTime? createdAt;

  IssueReport({
    this.id,
    this.referenceNumber,
    this.carRentalId,
    this.reporterId,
    this.reportSubject,
    this.reportDescription,
    this.status,
    this.createdAt,
  });
}
