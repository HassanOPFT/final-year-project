// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import '../utils/navigate_with_animation.dart';
import '../utils/snackbar.dart';
import '../controllers/customer_controller.dart';
import '../models/customer.dart';
import '../services/firebase/authentication/firebase_auth_service.dart';
import '../utils/assets_paths.dart';
import '../views/home/customer_explore_screen.dart';
import 'custom_progress_indicator.dart';

class ContinueWithGoogle extends StatefulWidget {
  const ContinueWithGoogle({super.key});

  @override
  State<ContinueWithGoogle> createState() => _ContinueWithGoogleState();
}

class _ContinueWithGoogleState extends State<ContinueWithGoogle> {
  final _firebaseAuthService = FirebaseAuthService();
  bool _isLoading = false;

  Future<void> _continueWithGoogle() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final userCredential = await _firebaseAuthService.continueWithGoogle();

      if (userCredential.user != null) {
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          // New User
          // create a customer using uid
          final customerId = userCredential.user?.uid;
          final customerEmail = userCredential.user?.email;
          final String customerFirstName =
              userCredential.additionalUserInfo?.profile?['given_name'] ?? '';
          final String customerLastName =
              userCredential.additionalUserInfo?.profile?['family_name'] ?? '';

          final customerController = CustomerController();
          await customerController.createCustomer(
            customer: Customer(
              userId: customerId,
              userEmail: customerEmail,
              userFirstName: customerFirstName,
              userLastName: customerLastName,
            ),
          );
        }
        animatedPushReplacementNavigation(
          context: context,
          screen: const CustomerExploreScreen(),
        );
      } else {
        if (mounted) {
          buildFailureSnackbar(
            context: context,
            message: 'Sign in with Google failed. Please try again.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        buildFailureSnackbar(
          context: context,
          message: 'Sign in with Google failed. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      child: _isLoading
          ? const CustomProgressIndicator()
          : ElevatedButton.icon(
              onPressed: _continueWithGoogle,
              icon: Image.asset(
                AssetsPaths.googleLogo,
                height: 30.0,
                width: 30.0,
                filterQuality: FilterQuality.medium,
                fit: BoxFit.cover,
              ),
              label: const Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
    );
  }
}
