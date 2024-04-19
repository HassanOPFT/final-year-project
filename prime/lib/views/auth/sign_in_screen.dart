import 'package:flutter/material.dart';

import '../../widgets/sign_up_prompt.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/continue_with_google.dart';
import '../../widgets/or_divider.dart';
import '../../widgets/sign_in_form.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppLogo(height: 240.0),
              SignInForm(),
              SizedBox(height: 20.0),
              OrDivider(),
              SizedBox(height: 20.0),
              ContinueWithGoogle(),
              SizedBox(height: 10.0),
              SignUpPrompt(),
            ],
          ),
        ),
      ),
    );
  }
}
