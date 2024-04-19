import 'package:flutter/material.dart';

import '../../services/firebase/authentication/firebase_auth_service.dart';
import 'customer_explore_screen.dart';
import '../auth/sign_in_screen.dart';
import '../auth/splash_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: FirebaseAuthService().currentUser,
      stream: FirebaseAuthService().authStateChanges,
      builder: (ctx, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (userSnapshot.hasData) {
          return const CustomerExploreScreen();
        } else {
          return const SignInScreen();
        }
      },
    );
  }
}
