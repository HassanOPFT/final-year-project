import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/bank_account.dart';

class BankAccountController {
  static const _bankAccountCollectionName = 'BankAccount';
  static const _hostIdFieldName = 'hostId';
  static const _accountHolderNameFieldName = 'accountHolderName';
  static const _bankNameFieldName = 'bankName';
  static const _accountNumberFieldName = 'accountNumber';
  static const _createdAtFieldName = 'createdAt';
  final _collection =
      FirebaseFirestore.instance.collection(_bankAccountCollectionName);

  Future<String> createBankAccount({
    required String hostId,
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
  }) async {
    if (hostId.isEmpty) {
      throw Exception('Host ID is required');
    }
    try {
      final newBankAccount = await _collection.add({
        _hostIdFieldName: hostId,
        _accountHolderNameFieldName: accountHolderName,
        _bankNameFieldName: bankName,
        _accountNumberFieldName: accountNumber,
        _createdAtFieldName: Timestamp.fromDate(DateTime.now()),
      });

      if (newBankAccount.id.isEmpty) {
        throw Exception('Failed to create bank account');
      }

      return newBankAccount.id;
    } catch (e) {
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
      await _collection.doc(bankAccountId).update({
        _accountHolderNameFieldName: accountHolderName,
        _bankNameFieldName: bankName,
        _accountNumberFieldName: accountNumber,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<BankAccount?> getBankAccountById(String bankAccountId) async {
    try {
      DocumentSnapshot doc = await _collection.doc(bankAccountId).get();

      if (doc.exists) {
        return BankAccount(
          id: doc.id,
          hostId: doc[_hostIdFieldName],
          accountHolderName: doc[_accountHolderNameFieldName],
          bankName: doc[_bankNameFieldName],
          accountNumber: doc[_accountNumberFieldName],
          createdAt: (doc[_createdAtFieldName] as Timestamp).toDate(),
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
  Future<BankAccount?> getBankAccountByHostId(String hostId) async {
    try {
      QuerySnapshot query = await _collection.where(_hostIdFieldName, isEqualTo: hostId).get();
      if (query.docs.isNotEmpty) {
        DocumentSnapshot doc = query.docs.first;
        return BankAccount(
          id: doc.id,
          hostId: doc[_hostIdFieldName],
          accountHolderName: doc[_accountHolderNameFieldName],
          bankName: doc[_bankNameFieldName],
          accountNumber: doc[_accountNumberFieldName],
          createdAt: (doc[_createdAtFieldName] as Timestamp).toDate(),
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBankAccount(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
}
