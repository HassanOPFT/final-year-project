import 'package:flutter/material.dart';

import '../views/auth/auth_screen.dart';
import '../utils/navigate_with_animation.dart';
import 'app_logo.dart';

class ErrorScreen extends StatelessWidget {
  final String errorMessage;

  const ErrorScreen({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final themeOfContext = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppLogo(height: 300.0),
              // const SizedBox(height: 16),
              Icon(
                Icons.error_outline,
                size: 60,
                color: themeOfContext.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => animatedPushReplacementNavigation(
                  context: context,
                  screen: const AuthScreen(),
                ),
                child: const Text(
                  'Okay',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
