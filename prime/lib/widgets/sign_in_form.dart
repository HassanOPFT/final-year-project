import 'package:flutter/material.dart';

import '../utils/navigate_with_animation.dart';
import '../utils/snackbar.dart';
import '../views/home/customer_explore_screen.dart';
import '../widgets/custom_progress_indicator.dart';
import '../services/firebase/authentication/firebase_auth_service.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // bool _rememberMe = true;
  bool _signInLoading = false;

  final _firebaseAuthService = FirebaseAuthService();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password.';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  Future<void> _signIn() async {
    if (mounted) {
      FocusScope.of(context).unfocus();
    }
    setState(() {
      _signInLoading = true;
    });
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        try {
          // Sign in user using Firebase Auth
          await _firebaseAuthService.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          if (_formKey.currentState != null) {
            _formKey.currentState!.reset();
          }

          setState(() {
            _signInLoading = false;
          });

          if (mounted) {
            animatedPushReplacementNavigation(
              context: context,
              screen: const CustomerExploreScreen(),
            );
          }
        } catch (e) {
          if (mounted) {
            buildFailureSnackbar(
              context: context,
              message: e.toString(),
            );
          }
        }
      }
    }
    if (mounted) {
      setState(() {
        _signInLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            focusNode: _emailFocusNode,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
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
              FocusScope.of(context).requestFocus(_passwordFocusNode);
            },
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            focusNode: _passwordFocusNode,
            textInputAction: TextInputAction.done,
            obscureText: true,
            validator: _validatePassword,
            controller: _passwordController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              prefixIcon: const Icon(Icons.lock),
              labelText: 'Password',
            ),
            onFieldSubmitted: (_) {
              _passwordFocusNode.unfocus();
              _signIn();
            },
          ),
          // const SizedBox(height: 10.0),
          // GestureDetector(
          //   onTap: () {
          //     setState(() {
          //       _rememberMe = !_rememberMe;
          //     });
          //   },
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Checkbox(
          //         value: _rememberMe,
          //         onChanged: (value) {
          //           if (value != null) {
          //             setState(() {
          //               _rememberMe = value;
          //             });
          //           }
          //         },
          //       ),
          //       const Text('Remember me'),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 30.0),
          SizedBox(
            height: 50.0,
            child: _signInLoading
                ? const CustomProgressIndicator()
                : FilledButton(
                    onPressed: _signIn,
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
