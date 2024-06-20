import 'package:flutter/material.dart';
import 'package:prime/providers/user_provider.dart';
import 'package:prime/utils/snackbar.dart';
import 'package:prime/views/host/add_car_screen.dart';
import 'package:provider/provider.dart';

import '../../models/verification_document.dart';
import '../../providers/bank_account_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/verification_document_provider.dart';
import '../../services/firebase/firebase_auth_service.dart';
import '../../utils/navigate_with_animation.dart';
import '../custom_progress_indicator.dart';

class AddCarFloatingButton extends StatefulWidget {
  const AddCarFloatingButton({super.key});

  @override
  State<AddCarFloatingButton> createState() => _AddCarFloatingButtonState();
}

class _AddCarFloatingButtonState extends State<AddCarFloatingButton> {
  final currentUserId = FirebaseAuthService().currentUser?.uid;

  bool _addCarLoading = false;
  void setAddCarLoading(bool value) {
    setState(() {
      _addCarLoading = value;
    });
  }

  Future<bool> hasApprovedIdentityDocument() async {
    try {
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );

      if (currentUserId == null || currentUserId!.isEmpty) {
        return false;
      }

      final identityDocumentId = await customerProvider.getIdentityDocumentId(
        currentUserId ?? '',
      );

      if (identityDocumentId.isEmpty) {
        return false;
      }

      // Check the status of the identity document
      final verificationDocumentProvider =
          Provider.of<VerificationDocumentProvider>(
        context,
        listen: false,
      );
      final identityDocument = await verificationDocumentProvider
          .getVerificationDocumentById(identityDocumentId);

      if (identityDocument == null ||
          identityDocument.status != VerificationDocumentStatus.approved) {
        // Identity document is not approved
        return false;
      }

      return true;
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<bool> hasBankAccount() async {
    try {
      if (currentUserId == null || currentUserId!.isEmpty) {
        return false;
      }

      final bankAccountProvider = Provider.of<BankAccountProvider>(
        context,
        listen: false,
      );
      final userBankAccount =
          await bankAccountProvider.getBankAccountByHostId(currentUserId ?? '');

      if (userBankAccount == null ||
          userBankAccount.accountHolderName!.isEmpty ||
          userBankAccount.accountNumber!.isEmpty ||
          userBankAccount.bankName!.isEmpty) {
        // User has no bank account record or incomplete bank account record
        return false;
      }

      return true;
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<bool> hasPhoneNumber() async {
    try {
      final userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );

      if (currentUserId == null || currentUserId!.isEmpty) {
        return false;
      }

      final currentUser =
          await userProvider.getUserDetails(currentUserId ?? '');

      if (currentUser == null) {
        return false;
      }

      if (currentUser.userPhoneNumber == null ||
          currentUser.userPhoneNumber!.isEmpty) {
        return false;
      }

      return true;
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<void> _addCar() async {
    try {
      setAddCarLoading(true);
      // check if the user has a approved identity in the database
      final hasApprovedIdentity = await hasApprovedIdentityDocument();
      if (!hasApprovedIdentity) {
        setAddCarLoading(false);
        if (mounted) {
          buildAlertSnackbar(
            context: context,
            message:
                'You need to have an approved identity document to add a car.',
          );
        }
        return;
      }

      // check if the user has a bank account in the database
      final hasBankAccountRecord = await hasBankAccount();
      if (!hasBankAccountRecord) {
        setAddCarLoading(false);
        if (mounted) {
          buildAlertSnackbar(
            context: context,
            message:
                'You need to have a bank account or complete bank account details to add a car.',
          );
        }
        return;
      }

      // check if the user has a phone no in the database
      final userHasPhoneNumber = await hasPhoneNumber();
      if (!userHasPhoneNumber) {
        setAddCarLoading(false);
        if (mounted) {
          buildAlertSnackbar(
            context: context,
            message:
                'You need to add a phone number to your profile to add a new car.',
          );
        }
        return;
      }

      setAddCarLoading(false);
      if (mounted) {
        animatedPushNavigation(
          context: context,
          screen: const AddCarScreen(),
        );
      }
    } on Exception catch (_) {
      setAddCarLoading(false);

      if (mounted) {
        buildFailureSnackbar(
          context: context,
          message: 'Error loading add car screen. Please try again later.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _addCar,
      label: _addCarLoading
          ? const CustomProgressIndicator()
          : const Text('Add New Car'),
      icon: _addCarLoading ? null : const Icon(Icons.car_rental_rounded),
    );
  }
}
