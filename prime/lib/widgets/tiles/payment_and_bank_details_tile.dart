import 'package:flutter/material.dart';

class PaymentAndBankDetails extends StatelessWidget {
  const PaymentAndBankDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.payment_rounded),
      title: const Text(
        'Payment & Bank Details',
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
      trailing: const Icon(Icons.keyboard_arrow_right_rounded),
      onTap: () {},
    );
  }
}
