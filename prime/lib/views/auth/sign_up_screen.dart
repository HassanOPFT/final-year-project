import 'package:flutter/material.dart';

import '../../widgets/app_logo.dart';
import '../../widgets/sign_up_form.dart';
import '../../widgets/continue_with_google.dart';
import '../../widgets/or_divider.dart';
import '../../widgets/sign_in_prompt.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogo(height: 240.0),
              const SignUpForm(),
              const SizedBox(height: 20.0),
              const OrDivider(),
              const SizedBox(height: 20.0),
              ContinueWithGoogle(),
              const SizedBox(height: 10.0),
              const SignInPrompt(),
            ],
          ),
        ),
      ),
    );
  }
}
