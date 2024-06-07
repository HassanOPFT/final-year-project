import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  final UserController _userController = UserController();
  User? _user;

  User? get user => _user;

  Future<void> initializeUser(String userId) async {
    _user = await _userController.getUserDetails(userId);
    notifyListeners();
  }

  Future<void> createUser({required User user}) async {
    try {
      await _userController.createUser(user: user);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, String?>> getUserNameAndPhoneNo() async {
    try {
      User? currentUser = _user;
      if (currentUser != null) {
        String? firstName = currentUser.userFirstName;
        String? lastName = currentUser.userLastName;
        String? phoneNumber = currentUser.userPhoneNumber;

        Map<String, String?> userInfo = {
          'userFirstName': firstName,
          'userLastName': lastName,
          'userPhoneNumber': phoneNumber,
        };

        return userInfo;
      } else {
        throw Exception('User data not available.');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> getUserDetails(String userId) async {
    try {
      final user = await _userController.getUserDetails(userId);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      await _userController.updateUserProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );
      if (_user != null) {
        _user!.userFirstName = firstName;
        _user!.userLastName = lastName;
        _user!.userPhoneNumber = phoneNumber;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserRole> getUserRole(String userId) async {
    try {
      final userRole = await _userController.getUserRole(userId);
      return userRole;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isUserRegistered(String email) async {
    try {
      final isRegistered = await _userController.isUserRegistered(email);
      return isRegistered;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getUserProfilePicture(String userId) async {
    try {
      final profilePicture =
          await _userController.getUserProfilePicture(userId);
      return profilePicture;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> uploadProfilePicture(String filePath, String userId) async {
    try {
      final downloadUrl =
          await _userController.uploadProfilePicture(filePath, userId);
      if (_user != null) {
        _user!.userProfileUrl = downloadUrl;
        notifyListeners();
      }
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProfilePicture(String userId) async {
    try {
      await _userController.deleteProfilePicture(userId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> getUsers({
    required List<String> usersRoles,
    required String currentUserId,
  }) async {
    try {
      final customers = await _userController.getUsers(
        usersRoles: usersRoles,
        currentUserId: currentUserId,
      );
      return customers;
    } catch (e) {
      rethrow;
    }
  }
}
