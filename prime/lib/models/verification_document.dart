class VerificationDocument {
  String? id;
  String? linkedObjectId;
  VerificationDocumentLinkedObjectType? linkedObjectType;
  String? documentUrl;
  VerificationDocumentType? documentType;
  VerificationDocumentStatus? status; // replace with status history id
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

enum VerificationDocumentLinkedObjectType {
  user,
  car,
}

enum VerificationDocumentType {
  identity,
  drivingLicense,
  carRegistration,
  carInsurance,
  carRoadTax,
}

extension VerificationDocumentTypeExtension on VerificationDocumentType {
  String getDocumentTypeString() {
    switch (this) {
      case VerificationDocumentType.identity:
        return 'Identity';
      case VerificationDocumentType.drivingLicense:
        return 'Driving License';
      case VerificationDocumentType.carRegistration:
        return 'Car Registration';
      case VerificationDocumentType.carInsurance:
        return 'Car Insurance';
      case VerificationDocumentType.carRoadTax:
        return 'Car Road Tax';
      default:
        return 'Unknown Type';
    }
  }
}

enum VerificationDocumentStatus {
  uploaded,
  pendingApproval,
  approved,
  rejected,
  updated,
  halted,
  unHaltRequested,
  deletedByCustomer,
  deletedByAdmin,
}

extension VerificationDocumentStatusExtension on VerificationDocumentStatus {
  String getStatusString() {
    switch (this) {
      case VerificationDocumentStatus.uploaded:
        return 'Uploaded';
      case VerificationDocumentStatus.pendingApproval:
        return 'Pending Approval';
      case VerificationDocumentStatus.approved:
        return 'Approved';
      case VerificationDocumentStatus.rejected:
        return 'Rejected';
      case VerificationDocumentStatus.updated:
        return 'Updated & Pending Approval';
      case VerificationDocumentStatus.halted:
        return 'Halted By Admin';
      case VerificationDocumentStatus.unHaltRequested:
        return 'Unhalt Requested';
      case VerificationDocumentStatus.deletedByCustomer:
        return 'Deleted by Customer';
      case VerificationDocumentStatus.deletedByAdmin:
        return 'Deleted by Admin';
      default:
        return 'Unknown Status';
    }
  }
}
