class RentalExtension {
  String? id;
  String? carRentalId;
  DateTime? startDate;
  DateTime? endDate;
  String? stripePaymentMethodId;
  DateTime? createdAt;

  RentalExtension({
    this.id,
    this.carRentalId,
    this.startDate,
    this.endDate,
    this.stripePaymentMethodId,
    this.createdAt,
  });
}
