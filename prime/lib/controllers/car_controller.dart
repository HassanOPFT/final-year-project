class CarController {
  static const String _carCollectionName = 'Car';
  static const String _idFieldName = 'id';
  static const String _hostIdFieldName = 'hostId';
  static const String _hostBankAccountIdFieldName = 'hostBankAccountId';
  static const String _defaultAddressIdFieldName = 'defaultAddressId';
  static const String _manufacturerFieldName = 'manufacturer';
  static const String _modelFieldName = 'model';
  static const String _manufactureYearFieldName = 'manufactureYear';
  static const String _colorFieldName = 'color';
  static const String _engineTypeFieldName = 'engineType';
  static const String _transmissionFieldName = 'transmission';
  static const String _seatsFieldName = 'seats';
  static const String _typeFieldName = 'type';
  static const String _hourPriceFieldName = 'hourPrice';
  static const String _dayPriceFieldName = 'dayPrice';
  static const String _imagesUrlFieldName = 'imagesUrl';
  static const String _descriptionFieldName = 'description';
  static const String _statusFieldName = 'status';
  static const String _registrationDocumentIdFieldName =
      'registrationDocumentId';
  static const String _roadTaxDocumentIdFieldName = 'roadTaxDocumentId';
  static const String _insuranceDocumentIdFieldName = 'insuranceDocumentId';
  static const String _referenceNumberFieldName = 'referenceNumber';
  static const String _createdAtFieldName = 'createdAt';
}

// carImages/${carId}/somethingHere.jpg all images in the carId folder
// car-insurance/${carId}_${randomString}.jpg
// car-registration/${carId}_${randomString}.jpg
// car-road-tax/${carId}_${randomString}.jpg
