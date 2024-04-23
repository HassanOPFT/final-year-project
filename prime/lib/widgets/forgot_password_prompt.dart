import 'package:flutter/material.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/views/auth/forgot_password_screen.dart';

class ForgotPasswordPrompt extends StatelessWidget {
  const ForgotPasswordPrompt({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        animatedPushNavigation(
          context: context,
          screen: const ForgotPasswordScreen(),
        );
      },
      child: const Text(
        'Forgot Password?',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
