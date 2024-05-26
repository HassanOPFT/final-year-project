import 'package:flutter/material.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/views/profile/payment_and_bank_account_screen.dart';

class PaymentCardsAndBankAccountTile extends StatelessWidget {
  const PaymentCardsAndBankAccountTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.payment_rounded),
      title: const Text(
        'Payment Cards & Bank Account',
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
      trailing: const Icon(Icons.keyboard_arrow_right_rounded),
      onTap: () => animatedPushNavigation(
        context: context,
        screen: const PaymentCardsAndBankAccountScreen(),
      ),
    );
  }
}
