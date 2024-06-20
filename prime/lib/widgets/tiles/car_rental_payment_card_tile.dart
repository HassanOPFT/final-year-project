import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/stripe_charge.dart';

class CarRentalPaymentCarTile extends StatelessWidget {
  final StripeCharge stripeCharge;

  const CarRentalPaymentCarTile({
    super.key,
    required this.stripeCharge,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.credit_card_rounded),
        title: Text(
          '${stripeCharge.cardBrand?.toUpperCase()} **** ${stripeCharge.cardLast4}',
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          DateFormat.yMMMd().add_jm().format(
                stripeCharge.createdAt ?? DateTime.now(),
              ),
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Text(
          'RM${stripeCharge.amount ?? '0.00'}',
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
