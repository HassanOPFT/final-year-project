class StripeTransaction {
  final String id;
  final double amount;
  final double fee;
  final double net;

  StripeTransaction({
    required this.id,
    required this.amount,
    required this.fee,
    required this.net,
  });

  factory StripeTransaction.fromJson(Map<String, dynamic> json) {
    return StripeTransaction(
      id: json['id'] as String,
      amount: (json['amount'] as int) / 100.0,
      fee: (json['fee'] as int) / 100.0,
      net: (json['net'] as int) / 100.0,
    );
  }
}
