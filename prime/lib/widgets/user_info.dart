import 'package:flutter/material.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';

import '../controllers/user_controller.dart';
import '../services/firebase/firebase_auth_service.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = FirebaseAuthService();
    final userId = authService.currentUser?.uid;
    if (userId == null) {
      return const Text('User not authenticated');
    }
    return FutureBuilder<Map<String, String?>>(
      future: UserController().getUserNameAndPhoneNo(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomProgressIndicator();
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Error fetching user info');
        } else {
          final userInfo = snapshot.data!;
          return Column(
            children: [
              Text(
                '${userInfo['userFirstName'] ?? ''} ${userInfo['userLastName'] ?? ''}',
                style: const TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (userInfo['userPhoneNumber'] != null &&
                  userInfo['userPhoneNumber']!.isNotEmpty)
                Text(
                  userInfo['userPhoneNumber'] ?? '',
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          );
        }
      },
    );
  }
}
