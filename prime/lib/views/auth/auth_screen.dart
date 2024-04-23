import 'package:flutter/material.dart';

import '../../services/firebase/firebase_auth_service.dart';
import '../auth/sign_in_screen.dart';
import '../auth/splash_screen.dart';
import '../home/home_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: FirebaseAuthService().currentUser,
      stream: FirebaseAuthService().authStateChanges,
      builder: (ctx, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (userSnapshot.hasData) {
          return const HomeScreen();
        } else {
          return const SignInScreen();
        }
      },
    );
  }
}
