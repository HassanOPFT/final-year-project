class Car {
  String? id;
  String? hostId;
  String? hostBankAccountId;
  String? defaultAddressId;
  String? manufacturer;
  String? model;
  int? manufactureYear;
  String? color;
  String? engineType;
  String? transmission;
  int? seats;
  String? type;
  double? hourPrice;
  double? dayPrice;
  List<String>? imagesUrl;
  String? description;
  String? status;
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
    this.transmission,
    this.seats,
    this.type,
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
