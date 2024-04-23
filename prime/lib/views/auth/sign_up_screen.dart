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
    return const Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppLogo(height: 200.0),
              SignUpForm(),
              SizedBox(height: 20.0),
              OrDivider(),
              SizedBox(height: 20.0),
              ContinueWithGoogle(),
              SizedBox(height: 10.0),
              SignInPrompt(),
            ],
          ),
        ),
      ),
    );
  }
}
