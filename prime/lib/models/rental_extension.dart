class RentalExtension {
  String? id;
  String? carRentalId;
  DateTime? startDate;
  DateTime? endDate;
  String? stripePaymentMethodId;
  String? referenceNumber;
  DateTime? createdAt;

  RentalExtension({
    this.id,
    this.carRentalId,
    this.startDate,
    this.endDate,
    this.stripePaymentMethodId,
    this.referenceNumber,
    this.createdAt,
  });
}
