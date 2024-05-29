import 'package:flutter/material.dart';

import '../../models/bank_account.dart';
import '../../providers/bank_account_provider.dart';
import '../../utils/navigate_with_animation.dart';
import '../../views/profile/payment_and_bank_account_screen.dart';
import '../custom_progress_indicator.dart';

class HostCarBankAccountCard extends StatelessWidget {
  const HostCarBankAccountCard({
    super.key,
    required BankAccountProvider bankAccountProvider,
    required this.hostBankAccountId,
  }) : _bankAccountProvider = bankAccountProvider;

  final BankAccountProvider _bankAccountProvider;
  final String hostBankAccountId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BankAccount?>(
      future: _bankAccountProvider.getBankAccountById(
        hostBankAccountId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomProgressIndicator();
        } else if (snapshot.hasError) {
          return const Center(
              child:
                  Text('Error loading bank account. Please try again later.'));
        } else if (snapshot.hasData && snapshot.data != null) {
          final bankAccount = snapshot.data!;
          return Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_rounded),
              title: Text(
                'Account Holder: ${bankAccount.accountHolderName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    'Bank Name: ${bankAccount.bankName}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Account Number: ${bankAccount.accountNumber}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'No Bank Account Found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => animatedPushNavigation(
                    context: context,
                    screen: const PaymentCardsAndBankAccountScreen(),
                  ),
                  child: const Text(
                    'Add Bank Account',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
