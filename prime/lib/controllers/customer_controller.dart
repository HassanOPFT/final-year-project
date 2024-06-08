import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_controller.dart';
import '../models/customer.dart';
import '../models/user.dart';
import '../utils/generate_reference_number.dart';

class CustomerController {
  static const String _customerCollectionName = 'Customer';

  static const String _defaultAddressIdFieldName = 'defaultAddressId';
  static const String _identityDocumentIdFieldName = 'identityDocumentId';
  static const String _drivingLicenseDocumentIdFieldName =
      'drivingLicenseDocumentId';
  static const String _stripeCustomerIdFieldName = 'stripeCustomerId';

  final _customerCollection =
      FirebaseFirestore.instance.collection(_customerCollectionName);
  final _userController = UserController();

  Future<void> createCustomer({required Customer customer}) async {
    try {
      if (customer.userId == null || customer.userId!.isEmpty) {
        throw Exception('Customer creation failed. Please try again.');
      }

      // Create a user in the User collection
      await _userController.createUser(user: _userFromCustomer(customer));

      // Create a customer in the Customer collection
      await _customerCollection.doc(customer.userId).set(
        {
          _defaultAddressIdFieldName: customer.defaultAddressId ?? '',
          _identityDocumentIdFieldName: customer.identityDocumentId ?? '',
          _drivingLicenseDocumentIdFieldName:
              customer.drivingLicenseDocumentId ?? '',
          _stripeCustomerIdFieldName: customer.stripeCustomerId ?? '',
        },
      );
    } catch (_) {
      rethrow;
    }
  }

  User _userFromCustomer(Customer customer) {
    return User(
      userId: customer.userId,
      userFirstName: customer.userFirstName,
      userLastName: customer.userLastName,
      userEmail: customer.userEmail,
      userRole: UserRole.customer,
      userReferenceNumber: generateReferenceNumber('CUST'),
      userProfileUrl: customer.userProfileUrl,
      userPhoneNumber: customer.userPhoneNumber,
      userFcmToken: customer.userFcmToken,
      userActivityStatus: ActivityStatus.active,
      notificationsEnabled: true,
    );
  }

  Future<void> setDefaultAddress({
    required String userId,
    required String addressId,
  }) async {
    try {
      if (userId.isEmpty || addressId.isEmpty) {
        throw Exception('Invalid userId or addressId');
      }
      await _customerCollection.doc(userId).update(
        {
          _defaultAddressIdFieldName: addressId,
        },
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<String> getCustomerDefaultAddress(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('Invalid userId');
      }
      final customer = await _customerCollection.doc(userId).get();
      return customer.get(_defaultAddressIdFieldName) as String;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteDefaultAddress(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('Invalid userId');
      }
      await _customerCollection.doc(userId).update(
        {
          _defaultAddressIdFieldName: '',
        },
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<void> setIdentityDocumentId({
    required String userId,
    required String documentId,
  }) async {
    try {
      if (userId.isEmpty || documentId.isEmpty) {
        throw Exception('Invalid userId or documentId');
      }
      await _customerCollection.doc(userId).update(
        {
          _identityDocumentIdFieldName: documentId,
        },
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<String> getIdentityDocumentId(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('Invalid userId');
      }
      final customer = await _customerCollection.doc(userId).get();
      return customer.get(_identityDocumentIdFieldName) as String;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteIdentityDocumentId(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('Invalid userId');
      }
      await _customerCollection.doc(userId).update(
        {
          _identityDocumentIdFieldName: '',
        },
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<void> setDrivingLicenseDocumentId({
    required String userId,
    required String documentId,
  }) async {
    try {
      if (userId.isEmpty || documentId.isEmpty) {
        throw Exception('Invalid userId or documentId');
      }
      await _customerCollection.doc(userId).update(
        {
          _drivingLicenseDocumentIdFieldName: documentId,
        },
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<String> getDrivingLicenseDocumentId(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('Invalid userId');
      }
      final customer = await _customerCollection.doc(userId).get();
      return customer.get(_drivingLicenseDocumentIdFieldName) as String;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteDrivingLicenseDocumentId(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('Invalid userId');
      }
      await _customerCollection.doc(userId).update(
        {
          _drivingLicenseDocumentIdFieldName: '',
        },
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<void> setStripeCustomerId({
    required String userId,
    required String stripeCustomerId,
  }) async {
    try {
      if (userId.isEmpty || stripeCustomerId.isEmpty) {
        throw Exception('Invalid userId or stripeCustomerId');
      }
      await _customerCollection.doc(userId).update(
        {
          _stripeCustomerIdFieldName: stripeCustomerId,
        },
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<String> getStripeCustomerId(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('Invalid userId');
      }
      final customer = await _customerCollection.doc(userId).get();
      return customer.get(_stripeCustomerIdFieldName) as String;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteStripeCustomerId(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('Invalid userId');
      }
      await _customerCollection.doc(userId).update(
        {
          _stripeCustomerIdFieldName: '',
        },
      );
    } catch (_) {
      rethrow;
    }
  }
}
