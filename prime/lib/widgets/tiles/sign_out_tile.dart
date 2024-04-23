// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:prime/views/auth/auth_screen.dart';

import '../../services/firebase/firebase_auth_service.dart';
import '../../utils/navigate_with_animation.dart';
import '../../utils/snackbar.dart';

class SignOutTile extends StatelessWidget {
  SignOutTile({super.key});
  final _firebaseAuthService = FirebaseAuthService();
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text(
        'Sign out',
        style: TextStyle(
          fontSize: 20.0,
          color: Colors.red,
        ),
      ),
      leading: const Icon(
        Icons.logout,
        color: Colors.red,
      ),
      onTap: () async {
        try {
          await _firebaseAuthService.signOut();
          animatedPushReplacementNavigation(
            context: context,
            screen: const AuthScreen(),
          );
        } catch (e) {
          buildFailureSnackbar(
            context: context,
            message: e.toString(),
          );
        }
      },
    );
  }
}
