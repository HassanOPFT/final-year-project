import 'package:flutter/material.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/widgets/bank_account_form_screen.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';

import '../providers/bank_account_provider.dart';
import '../models/bank_account.dart';
import '../services/firebase/firebase_auth_service.dart';
import 'card/bank_account_details_card.dart';
import 'no_data_found.dart';

class BankAccountTabBody extends StatelessWidget {
  const BankAccountTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseAuthService = FirebaseAuthService();
    final bankAccountProvider = Provider.of<BankAccountProvider>(context);

    return FutureBuilder<BankAccount?>(
      future: bankAccountProvider.getBankAccountByHostId(
        firebaseAuthService.currentUser?.uid ?? '',
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomProgressIndicator();
        } else if (snapshot.hasError) {
          return const Center(
              child:
                  Text('Error loading bank account. please try again later.'));
        } else if (snapshot.hasData && snapshot.data != null) {
          final bankAccount = snapshot.data!;
          return Column(
            children: [
              BankAccountDetailsCard(bankAccount: bankAccount),
            ],
          );
        } else {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Flexible(
                  flex: 6,
                  child: NoDataFound(
                    title: 'No Bank Account Found',
                    subTitle:
                        'Add your bank account to be able to receive payments. You need to add your bank account to be able to register your car.',
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: () => animatedPushNavigation(
                        context: context,
                        screen: const BankAccountFormScreen(isUpdate: false),
                      ),
                      child: const Text(
                        'Add Bank Account',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
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
