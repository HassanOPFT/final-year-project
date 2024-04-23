import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/dialog_utils.dart';
import '../../utils/snackbar.dart';
import '../../widgets/app_logo.dart';
import '../../controllers/user_controller.dart';
import '../../services/firebase/firebase_auth_service.dart';
import '../../widgets/custom_progress_indicator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _resetPasswordLoading = false;
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _firebaseAuthService = FirebaseAuthService();
  final _userController = UserController();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address.';
    } else if (!RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*",
    ).hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  void _resetPassword() async {
    String? emailError = _validateEmail(_emailController.text.trim());
    if (emailError != null) {
      buildFailureSnackbar(context: context, message: emailError);
      return;
    }

    setState(() {
      _resetPasswordLoading = true;
    });

    try {
      bool isUserRegistered =
          await _userController.isUserRegistered(_emailController.text.trim());

      if (!isUserRegistered) {
        if (mounted) {
          DialogUtils.showErrorDialog(
            context: context,
            message: 'You are not registered with us. Please sign up.',
          );
        }
        return;
      }

      await _firebaseAuthService
          .sendPasswordResetEmail(_emailController.text.trim());

      if (mounted) {
        DialogUtils.showSuccessDialog(
          context: context,
          message:
              'Password reset email sent successfully. Please check your email.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        buildFailureSnackbar(
          context: context,
          message: e.message ?? 'An error occurred. Please try again.',
        );
      }
    } on Exception catch (_) {
      if (mounted) {
        buildFailureSnackbar(
          context: context,
          message: 'An error occurred. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _resetPasswordLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppLogo(height: 150.0),
              const Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Enter your email address associated with your account and we will send you an email with instructions to reset your password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 30.0),
              TextFormField(
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: const Icon(Icons.email),
                  labelText: 'Email',
                ),
                onFieldSubmitted: (_) {
                  _emailFocusNode.unfocus();
                  _resetPassword();
                },
              ),
              const SizedBox(height: 40.0),
              SizedBox(
                height: 50.0,
                child: _resetPasswordLoading
                    ? const CustomProgressIndicator()
                    : FilledButton(
                        onPressed: _resetPassword,
                        child: const Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 15.0),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              //const SizedBox(height: 60.0)
            ],
          ),
        ),
      ),
    );
  }
}
