class Car {
  String? id;
  String? hostId;
  String? hostBankAccountId;
  String? defaultAddressId;
  String? manufacturer;
  String? model;
  int? manufactureYear;
  String? color;
  EngineType? engineType;
  TransmissionType? transmissionType;
  int? seats;
  CarType? carType;
  double? hourPrice;
  double? dayPrice;
  List<String>? imagesUrl;
  String? description;
  CarStatus? status;
  String? registrationDocumentId;
  String? roadTaxDocumentId;
  String? insuranceDocumentId;
  String? referenceNumber;
  DateTime? createdAt;

  Car({
    this.id,
    this.hostId,
    this.hostBankAccountId,
    this.defaultAddressId,
    this.manufacturer,
    this.model,
    this.manufactureYear,
    this.color,
    this.engineType,
    this.transmissionType,
    this.seats,
    this.carType,
    this.hourPrice,
    this.dayPrice,
    this.imagesUrl,
    this.description,
    this.status,
    this.registrationDocumentId,
    this.roadTaxDocumentId,
    this.insuranceDocumentId,
    this.referenceNumber,
    this.createdAt,
  });
}

enum CarStatus {
  currentlyRented,
  upcomingRental,
  uploaded,
  pendingApproval,
  updated,
  approved,
  rejected,
  haltedByHost,
  haltedByAdmin,
  unhaltRequested,
  deletedByHost,
  deletedByAdmin,
}

extension CarStatusExtension on CarStatus {
  String getCarStatusString() {
    switch (this) {
      case CarStatus.currentlyRented:
        return 'Currently Rented';
      case CarStatus.upcomingRental:
        return 'Upcoming Rental';
      case CarStatus.uploaded:
        return 'Uploaded';
      case CarStatus.pendingApproval:
        return 'Pending Approval';
      case CarStatus.updated:
        return 'Updated & Pending Approval';
      case CarStatus.approved:
        return 'Available for Rent';
      case CarStatus.rejected:
        return 'Rejected';
      case CarStatus.haltedByHost:
        return 'Halted by Host';
      case CarStatus.haltedByAdmin:
        return 'Halted by Admin';
      case CarStatus.unhaltRequested:
        return 'Unhalt Requested';
      case CarStatus.deletedByHost:
        return 'Deleted by Host';
      case CarStatus.deletedByAdmin:
        return 'Deleted by Admin';
      default:
        return 'Unknown Status';
    }
  }
}

enum CarType {
  sedan,
  hatchback,
  suv,
  van,
  truck,
}

extension CarTypeExtension on CarType {
  String getCarTypeString() {
    switch (this) {
      case CarType.sedan:
        return 'Sedan';
      case CarType.hatchback:
        return 'Hatchback';
      case CarType.suv:
        return 'SUV';
      case CarType.van:
        return 'Van';
      case CarType.truck:
        return 'Truck';
      default:
        return 'Unknown Type';
    }
  }
}

enum EngineType {
  gasoline,
  diesel,
  electric,
  hybrid,
}

extension EngineTypeExtension on EngineType {
  String get engineTypeString {
    switch (this) {
      case EngineType.gasoline:
        return 'Gasoline';
      case EngineType.diesel:
        return 'Diesel';
      case EngineType.electric:
        return 'Electric';
      case EngineType.hybrid:
        return 'Hybrid';
      default:
        return 'Unknown Type';
    }
  }
}

enum TransmissionType {
  manual,
  automatic,
  semiAutomatic,
}

extension TransmissionTypeExtension on TransmissionType {
  String get transmissionTypeString {
    switch (this) {
      case TransmissionType.manual:
        return 'Manual';
      case TransmissionType.automatic:
        return 'Automatic';
      case TransmissionType.semiAutomatic:
        return 'Semi-Automatic';
      default:
        return 'Unknown Type';
    }
  }
}
