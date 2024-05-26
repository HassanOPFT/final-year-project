import 'package:flutter/material.dart';

import '../controllers/bank_account_controller.dart';
import '../models/bank_account.dart';

class BankAccountProvider extends ChangeNotifier {
  final _bankAccountController = BankAccountController();

  Future<String> createBankAccount({
    required String hostId,
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
  }) async {
    try {
      final newBankAccountId = await _bankAccountController.createBankAccount(
        hostId: hostId,
        accountHolderName: accountHolderName,
        bankName: bankName,
        accountNumber: accountNumber,
      );
      notifyListeners();
      return newBankAccountId;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateBankAccount({
    required String bankAccountId,
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
  }) async {
    try {
      await _bankAccountController.updateBankAccount(
        bankAccountId: bankAccountId,
        accountHolderName: accountHolderName,
        bankName: bankName,
        accountNumber: accountNumber,
      );
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<BankAccount?> getBankAccountById(String bankAccountId) async {
    try {
      final bankAccount =
          await _bankAccountController.getBankAccountById(bankAccountId);
      return bankAccount;
    } catch (_) {
      rethrow;
    }
  }

  Future<BankAccount?> getBankAccountByHostId(String hostId) async {
    try {
      final bankAccount =
          await _bankAccountController.getBankAccountByHostId(hostId);
      return bankAccount;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteBankAccount(String id) async {
    try {
      await _bankAccountController.deleteBankAccount(id);
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }
}
