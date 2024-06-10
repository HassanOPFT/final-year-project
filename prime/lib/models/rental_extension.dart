class RentalExtension {
  String? id;
  String? carRentalId;
  DateTime? startDate;
  DateTime? endDate;
  String? stripeChargeId;
  String? referenceNumber;
  DateTime? createdAt;

  RentalExtension({
    this.id,
    this.carRentalId,
    this.startDate,
    this.endDate,
    this.stripeChargeId,
    this.referenceNumber,
    this.createdAt,
  });
}
