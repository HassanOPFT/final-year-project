import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';
import '../services/firebase/firebase_storage_service.dart';

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

  // create getter for defaultProfileUrl
  String get defaultProfileUrl =>
      'https://firebasestorage.googleapis.com/v0/b/prime-b09b7.appspot.com/o/default-files%2Fuser-default-profile-picture.jpg?alt=media&token=4acacd32-a06e-4637-a5af-357c986caca3';

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
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<Map<String, String?>> getUserNameAndPhoneNo(String userId) async {
    try {
      final userSnapshot = await _userCollection.doc(userId).get();
      if (userSnapshot.exists) {
        final data = userSnapshot.data();
        if (data != null) {
          return {
            _firstNameFieldName: data[_firstNameFieldName] as String?,
            _lastNameFieldName: data[_lastNameFieldName] as String?,
            _phoneNumberFieldName: data[_phoneNumberFieldName] as String?,
          };
        }
      }
      return {};
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<UserRole> getUserRole(String userId) async {
    try {
      final userSnapshot = await _userCollection.doc(userId).get();
      if (!userSnapshot.exists) {
        throw Exception('User not found.');
      }
      dynamic data = userSnapshot.data();

      if (data == null) {
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

  Future<bool> isUserRegistered(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _userCollection
          .where(
            _emailFieldName,
            isEqualTo: email,
          )
          .get();

      return querySnapshot.docs.isNotEmpty;
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<String?> getUserProfilePicture(String userId) async {
    try {
      final userSnapshot = await _userCollection.doc(userId).get();
      if (userSnapshot.exists) {
        final data = userSnapshot.data();
        if (data != null && data[_profileUrlFieldName] != null) {
          return data[_profileUrlFieldName] as String;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _generateProfilePictureStoragePath(String userReferenceNumber) {
    return 'user-profile-picture/$userReferenceNumber.jpg';
  }

  // user-profile-picture/${userReferenceNumber}.jpg
  Future<String?> uploadProfilePicture(String filePath, String userId) async {
    try {
      // Get user reference number
      final userReferenceNumber = await getUserReferenceNumber(userId);

      if (userReferenceNumber != null) {
        final firebaseStorageService = FirebaseStorageService();
        final storagePath =
            _generateProfilePictureStoragePath(userReferenceNumber);
        final downloadUrl = await firebaseStorageService.uploadFile(
          filePath: filePath,
          storagePath: storagePath,
        );
        if (downloadUrl != null) {
          await _userCollection.doc(userId).update({
            _profileUrlFieldName: downloadUrl,
          });
          return downloadUrl;
        }
      }
      return null;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteProfilePicture(String userId) async {
    try {
      final userReferenceNumber = await getUserReferenceNumber(userId);
      if (userReferenceNumber != null) {
        final firebaseStorageService = FirebaseStorageService();
        final storagePath =
            _generateProfilePictureStoragePath(userReferenceNumber);
        // Update default profile image URL in Firestore
        await _userCollection.doc(userId).update({
          _profileUrlFieldName: defaultProfileUrl,
        });
        // Delete profile picture from Firebase Storage
        await firebaseStorageService.deleteFile(storagePath);
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<String?> getUserReferenceNumber(String userId) async {
    try {
      final userSnapshot = await _userCollection.doc(userId).get();
      if (userSnapshot.exists) {
        final data = userSnapshot.data();
        if (data != null && data[_referenceNumberFieldName] != null) {
          return data[_referenceNumberFieldName] as String?;
        }
      }
      return null;
    } catch (_) {
      rethrow;
    }
  }
}
