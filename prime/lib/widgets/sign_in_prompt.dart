import 'package:flutter/material.dart';

import '../utils/navigate_with_animation.dart';
import '../views/auth/sign_in_screen.dart';

class SignInPrompt extends StatelessWidget {
  const SignInPrompt({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: TextStyle(
            color: Theme.of(context).dividerColor,
          ),
        ),
        TextButton(
          onPressed: () => animatedPushReplacementNavigation(
            screen: const SignInScreen(),
            context: context,
          ),
          child: const Text(
            'Sign in',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    );
  }
}
