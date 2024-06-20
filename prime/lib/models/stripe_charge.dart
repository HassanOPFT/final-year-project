class StripeCharge {
  final String? id;
  final double? amount;
  final String? balanceTransactionId;
  final String? paymentMethodId;
  final String? cardBrand;
  final int? cardExpiryMonth;
  final int? cardExpiryYear;
  final String? cardLast4;
  final String? receiptEmail;
  final String? receiptUrl;
  final DateTime? createdAt;

  StripeCharge({
    required this.id,
    required this.amount,
    required this.balanceTransactionId,
    required this.paymentMethodId,
    required this.cardBrand,
    required this.cardExpiryMonth,
    required this.cardExpiryYear,
    required this.cardLast4,
    required this.receiptEmail,
    required this.receiptUrl,
    required this.createdAt,
  });

  factory StripeCharge.fromJson(Map<String, dynamic> json) {
    final paymentMethodDetails = json['payment_method_details']['card'];
    final int createdTimestamp = json['created'];
    final DateTime createdAt =
        DateTime.fromMillisecondsSinceEpoch(createdTimestamp * 1000);

    return StripeCharge(
      id: json['id'],
      amount: json['amount'] / 100,
      balanceTransactionId: json['balance_transaction'],
      paymentMethodId: json['payment_method'],
      cardBrand: paymentMethodDetails['brand'],
      cardExpiryMonth: paymentMethodDetails['exp_month'],
      cardExpiryYear: paymentMethodDetails['exp_year'],
      cardLast4: paymentMethodDetails['last4'],
      receiptEmail: json['receipt_email'],
      receiptUrl: json['receipt_url'],
      createdAt: createdAt,
    );
  }
}
