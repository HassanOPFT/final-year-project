// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/providers/car_provider.dart';
import 'package:prime/utils/assets_paths.dart';
import 'package:prime/utils/snackbar.dart';
import 'package:provider/provider.dart';

import '../../models/bank_account.dart';
import '../../providers/bank_account_provider.dart';
import '../../utils/navigate_with_animation.dart';
import '../bank_account_form_screen.dart';

class BankAccountDetailsCard extends StatelessWidget {
  final BankAccount bankAccount;
  const BankAccountDetailsCard({
    super.key,
    required this.bankAccount,
  });

  @override
  Widget build(BuildContext context) {
    Provider.of<BankAccountProvider>(context);

    Future<bool> confirmDeleteBankAccount(BuildContext context) async {
      bool isConfirmed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AssetsPaths.binImage,
                  height: 200.0,
                ),
                const Text(
                  'Are you sure you want to delete this bank account? This action cannot be undone.',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      return isConfirmed;
    }

    Future<void> deleteBankAccount() async {
      // check if the the hostId associated with this bank account is used in any car in the database, if it is, do not delete and alert the user
      final carProvider = Provider.of<CarProvider>(
        context,
        listen: false,
      );
      final hasCars =
          await carProvider.hasCarsWithHostId(bankAccount.hostId ?? '');

      if (hasCars) {
        buildAlertSnackbar(
          context: context,
          message:
              'Cannot delete bank account. There is a car or cars associated with this bank account.',
        );
        return;
      }

      bool confirmDeletion = await confirmDeleteBankAccount(context);
      if (!confirmDeletion) {
        return;
      }

      final bankAccountProvider = Provider.of<BankAccountProvider>(
        context,
        listen: false,
      );

      try {
        await bankAccountProvider.deleteBankAccount(bankAccount.id!);
        buildSuccessSnackbar(
          context: context,
          message: 'Bank account deleted successfully.',
        );
      } catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error deleting bank account. Please try again later.',
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // add big bank icon here
                  const SizedBox(height: 20.0),
                  const Icon(
                    Icons.account_balance_rounded,
                    size: 80.0,
                  ),
                  const SizedBox(height: 20.0),
                  _buildDetailRow(
                    label: 'Bank Account Holder',
                    value: bankAccount.accountHolderName ?? 'N/A',
                  ),
                  _buildDetailRow(
                    label: 'Bank Name',
                    value: bankAccount.bankName ?? 'N/A',
                  ),
                  _buildDetailRow(
                    label: 'Account Number',
                    value: bankAccount.accountNumber ?? 'N/A',
                  ),
                  _buildDetailRow(
                    label: 'Created At',
                    value: bankAccount.createdAt != null
                        ? DateFormat.yMMMMd()
                            .add_jm()
                            .format(bankAccount.createdAt as DateTime)
                        : 'N/A',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30.0),
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: () => animatedPushNavigation(
                context: context,
                screen: BankAccountFormScreen(
                  isUpdate: true,
                  bankAccount: bankAccount,
                ),
              ),
              child: const Text(
                'Update Bank Account',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 30.0),
          SizedBox(
            height: 50,
            child: TextButton(
              onPressed: deleteBankAccount,
              child: const Text(
                'Delete Bank Account',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22.0,
              // fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
