// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:prime/providers/user_provider.dart';
import 'package:prime/views/auth/auth_screen.dart';
import 'package:provider/provider.dart';

import '../../services/firebase/firebase_auth_service.dart';
import '../../utils/navigate_with_animation.dart';
import '../../utils/snackbar.dart';

class SignOutTile extends StatelessWidget {
  SignOutTile({super.key});
  final _firebaseAuthService = FirebaseAuthService();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          final currentUserId = FirebaseAuthService().currentUser?.uid;
          if (currentUserId != null) {
            await Provider.of<UserProvider>(context, listen: false)
                .deleteUserFcmToken(
              currentUserId,
            );
          }
          await _firebaseAuthService.signOut();
          animatedPushReplacementNavigation(
            context: context,
            screen: const AuthScreen(),
          );
        } catch (_) {
          buildFailureSnackbar(
            context: context,
            message: 'Failed to sign out. Please try again.',
          );
        }
      },
      child: const ListTile(
        title: Text(
          'Sign out',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.red,
          ),
        ),
        leading: Icon(
          Icons.logout,
          color: Colors.red,
        ),
      ),
    );
  }
}
