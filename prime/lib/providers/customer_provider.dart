import 'package:flutter/material.dart';

import '../controllers/customer_controller.dart';

class CustomerProvider extends ChangeNotifier {
  final _customerController = CustomerController();

  Future<void> setDefaultAddress({
    required String userId,
    required String addressId,
  }) async {
    try {
      await _customerController.setDefaultAddress(
        userId: userId,
        addressId: addressId,
      );
      notifyListeners();
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<String> getDefaultAddress(String userId) async {
    try {
      final defaultAddressId =
          await _customerController.getCustomerDefaultAddress(userId);
      return defaultAddressId;
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<void> deleteDefaultAddress(String userId) async {
    try {
      await _customerController.deleteDefaultAddress(userId);
      notifyListeners();
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<void> setIdentityDocumentId({
    required String userId,
    required String documentId,
  }) async {
    try {
      await _customerController.setIdentityDocumentId(
        userId: userId,
        documentId: documentId,
      );
      notifyListeners();
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<String> getIdentityDocumentId(String userId) async {
    try {
      final documentId =
          await _customerController.getIdentityDocumentId(userId);
      return documentId;
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<void> deleteIdentityDocumentId(String userId) async {
    try {
      await _customerController.deleteIdentityDocumentId(userId);
      notifyListeners();
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<void> setLicenseDocumentId({
    required String userId,
    required String documentId,
  }) async {
    try {
      await _customerController.setDrivingLicenseDocumentId(
        userId: userId,
        documentId: documentId,
      );
      notifyListeners();
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<String> getLicenseDocumentId(String userId) async {
    try {
      final documentId =
          await _customerController.getDrivingLicenseDocumentId(userId);
      return documentId;
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<void> deleteLicenseDocumentId(String userId) async {
    try {
      await _customerController.deleteDrivingLicenseDocumentId(userId);
      notifyListeners();
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<void> setStripeAccountId({
    required String userId,
    required String stripeCustomerId,
  }) async {
    try {
      await _customerController.setStripeCustomerId(
        userId: userId,
        stripeCustomerId: stripeCustomerId,
      );
      notifyListeners();
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<String> getStripeAccountId(String userId) async {
    try {
      final accountId = await _customerController.getStripeCustomerId(userId);
      return accountId;
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<void> deleteStripeAccountId(String userId) async {
    try {
      await _customerController.deleteStripeCustomerId(userId);
      notifyListeners();
    } on Exception catch (_) {
      rethrow;
    }
  }
}
