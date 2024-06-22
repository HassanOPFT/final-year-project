class IssueReport {
  String? id;
  String? carRentalId;
  String? reporterId;
  String? reportSubject;
  String? reportDescription;
  IssueReportStatus? status;
  String? referenceNumber;
  DateTime? createdAt;

  IssueReport({
    this.id,
    this.carRentalId,
    this.reporterId,
    this.reportSubject,
    this.reportDescription,
    this.status,
    this.referenceNumber,
    this.createdAt,
  });

  factory IssueReport.fromMap(String id, Map<String, dynamic> map) {
    return IssueReport(
      id: id,
      carRentalId: map['carRentalId'],
      reporterId: map['reporterId'],
      reportSubject: map['reportSubject'],
      reportDescription: map['reportDescription'],
      status: map['status'] != null
          ? IssueReportStatus.values.firstWhere(
              (status) => status.name == map['status'],
              orElse: () => IssueReportStatus.open,
            )
          : null,
      referenceNumber: map['referenceNumber'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['createdAt'].millisecondsSinceEpoch)
          : null,
    );
  }
}

enum IssueReportStatus {
  open,
  inProgress,
  resolved,
  closed,
}

extension IssueReportStatusExtension on IssueReportStatus {
  String getStatusString() {
    switch (this) {
      case IssueReportStatus.open:
        return 'Open';
      case IssueReportStatus.inProgress:
        return 'In Progress';
      case IssueReportStatus.resolved:
        return 'Resolved';
      case IssueReportStatus.closed:
        return 'Closed';
      default:
        return 'Unknown Status';
    }
  }
}
