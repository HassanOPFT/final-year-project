import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';

class UserController {
  static const String _userCollectionName = 'User';
  static const String _firstNameFieldName = 'userFirstName';
  static const String _lastNameFieldName = 'userLastName';
  static const String _emailFieldName = 'userEmail';
  static const String _roleFieldName = 'userRole';
  static const String _referenceNumberFieldName = 'userReferenceNumber';
  static const String _profileUrlFieldName = 'userProfileUrl';
  static const String _phoneNumberFieldName = 'userPhoneNumber';
  static const String _fcmTokenFieldName = 'userFcmToken';
  static const String _activityStatusFieldName = 'userActivityStatus';
  static const String _notificationsEnabledFieldName = 'notificationsEnabled';
  static const String _createdAtFieldName = 'createdAt';

  final _userCollection =
      FirebaseFirestore.instance.collection(_userCollectionName);

  Future<void> createUser({required User user}) async {
    try {
      await _userCollection.doc(user.userId).set(
        {
          _firstNameFieldName: user.userFirstName,
          _lastNameFieldName: user.userLastName,
          _emailFieldName: user.userEmail,
          _roleFieldName: user.userRole?.name ?? UserRole.customer.name,
          _referenceNumberFieldName: user.userReferenceNumber,
          _profileUrlFieldName: user.userProfileUrl ?? '',
          _phoneNumberFieldName: user.userPhoneNumber ?? '',
          _fcmTokenFieldName: user.userFcmToken ?? '',
          _activityStatusFieldName:
              user.userActivityStatus?.name ?? ActivityStatus.active.name,
          _notificationsEnabledFieldName: user.notificationsEnabled,
          _createdAtFieldName: Timestamp.now(),
        },
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<UserRole> getUserRole(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await _userCollection.doc(userId).get();
      if (!userSnapshot.exists) {
        throw Exception('User not found.');
      }
      dynamic data = userSnapshot.data();
      if (data == null || data.runtimeType != Map) {
        throw Exception('Invalid data format in Firestore.');
      }
      UserRole userRole = UserRole.customer;
      Map<String, dynamic> userData = data as Map<String, dynamic>;
      if (userData.containsKey(_roleFieldName)) {
        userRole = UserRole.values.firstWhere(
          (role) => role.name == userData[_roleFieldName],
          orElse: () => UserRole.customer,
        );
      }
      return userRole;
    } catch (e) {
      rethrow;
    }
  }
}
