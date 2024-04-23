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
    return const Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppLogo(height: 240.0),
              SignInForm(),
              SizedBox(height: 20.0),
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
