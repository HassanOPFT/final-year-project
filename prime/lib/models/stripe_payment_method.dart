class StripePaymentMethod {
  final String? paymentMethodId;
  final String? cardBrand;
  final int? cardExpiryMonth;
  final int? cardExpiryYear;
  final String? cardLast4;
  final String? customerId;
  StripePaymentMethod({
    required this.paymentMethodId,
    required this.cardBrand,
    required this.cardExpiryMonth,
    required this.cardExpiryYear,
    required this.cardLast4,
    required this.customerId,
  });
  factory StripePaymentMethod.fromMap(Map<String, dynamic> map) {
    return StripePaymentMethod(
      paymentMethodId: map['id'],
      cardBrand: map['card']['brand'],
      cardExpiryMonth: map['card']['exp_month'],
      cardExpiryYear: map['card']['exp_year'],
      cardLast4: map['card']['last4'],
      customerId: map['customer'],
    );
  }
}
