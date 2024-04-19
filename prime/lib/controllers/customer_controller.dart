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
}
