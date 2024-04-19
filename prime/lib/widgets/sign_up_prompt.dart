import 'package:flutter/material.dart';

import '../utils/navigate_with_animation.dart';
import '../views/auth/sign_up_screen.dart';

class SignUpPrompt extends StatelessWidget {
  const SignUpPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account yet?',
          style: TextStyle(
            color: Theme.of(context).dividerColor,
          ),
        ),
        TextButton(
          onPressed: () => animatedPushReplacementNavigation(
            screen: const SignUpScreen(),
            context: context,
          ),
          child: const Text(
            'Sign up',
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
