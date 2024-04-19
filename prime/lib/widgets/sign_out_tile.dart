// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import '../services/firebase/authentication/firebase_auth_service.dart';
import '../utils/navigate_with_animation.dart';
import '../utils/snackbar.dart';
import '../views/home/home_screen.dart';

class SignOutTile extends StatelessWidget {
  SignOutTile({super.key});
  final _firebaseAuthService = FirebaseAuthService();
  @override
  Widget build(BuildContext context) {
    final themeOfContext = Theme.of(context);
    return ListTile(
      title: Text(
        'Sign out',
        style: TextStyle(
          fontSize: 20.0,
          color: themeOfContext.colorScheme.error,
        ),
      ),
      leading: Icon(
        Icons.logout,
        color: themeOfContext.colorScheme.error,
      ),
      onTap: () async {
        try {
          await _firebaseAuthService.signOut();
          animatedPushReplacementNavigation(
            context: context,
            screen: const HomeScreen(),
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
