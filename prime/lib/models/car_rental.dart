class CarRental {
  String? id;
  String? carId;
  String? customerId;
  DateTime? startDate;
  DateTime? endDate;
  double? rating;
  String? review;
  String? status;
  String? referenceNumber;
  String? stripePaymentMethodId;
  int? extensionCount;
  DateTime? createdAt;

  CarRental({
    this.id,
    this.carId,
    this.customerId,
    this.startDate,
    this.endDate,
    this.rating,
    this.review,
    this.status,
    this.referenceNumber,
    this.stripePaymentMethodId,
    this.extensionCount,
    this.createdAt,
  });
}
