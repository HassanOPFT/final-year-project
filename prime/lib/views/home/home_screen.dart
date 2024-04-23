import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../controllers/user_controller.dart';
import '../../models/user.dart';
import '../../utils/navigate_with_animation.dart';
import '../../widgets/error_screen.dart';
import '../auth/auth_screen.dart';
import '../auth/splash_screen.dart';
import 'admin_dashboard_screen.dart';
import 'customer_explore_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userController = UserController();

    if (user == null) {
      animatedPushReplacementNavigation(
        context: context,
        screen: const AuthScreen(),
      );
      return Container();
    }

    return FutureBuilder<UserRole>(
      future: userController.getUserRole(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (snapshot.hasError) {
          return const ErrorScreen(
            errorMessage: 'Error Signing In. Please try again.',
          );
        } else {
          final userRole = snapshot.data;
          return userRole == UserRole.primaryAdmin ||
                  userRole == UserRole.secondaryAdmin
              ? const AdminDashboardScreen()
              : const CustomerExploreScreen();
        }
      },
    );
  }
}
