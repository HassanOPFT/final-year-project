// ignore_for_file: use_build_context_synchronously

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../controllers/user_controller.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../utils/navigate_with_animation.dart';
import '../../widgets/error_screen.dart';
import '../auth/auth_screen.dart';
import '../auth/splash_screen.dart';
import 'admin_dashboard_screen.dart';
import 'customer_explore_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _setupFCMTokenRefreshListener();
  }

  void _setupFCMTokenRefreshListener() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
        Provider.of<UserProvider>(
          context,
          listen: false,
        ).updateUserFCMToken(userId, fcmToken);
      });
    }
  }

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

    // Method to update FCM token
    Future<void> updateFCMToken(String userId) async {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await Provider.of<UserProvider>(
          context,
          listen: false,
        ).updateUserFCMToken(userId, token);
      }
    }

    return FutureBuilder(
      future: Future.wait([
        userController.getUserRole(user.uid),
        Provider.of<UserProvider>(
          context,
          listen: false,
        ).initializeUser(
          user.uid,
        ),
        updateFCMToken(user.uid),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (snapshot.hasError) {
          return const ErrorScreen(
            errorMessage: 'Error Signing In. Please try again.',
          );
        } else {
          final userRole = snapshot.data!.first as UserRole;
          return userRole == UserRole.primaryAdmin ||
                  userRole == UserRole.secondaryAdmin
              ? const AdminDashboardScreen()
              : const CustomerExploreScreen();
        }
      },
    );
  }
}
