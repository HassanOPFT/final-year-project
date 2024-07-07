import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prime/views/home/home_screen.dart';

import '../utils/navigate_with_animation.dart';
import '../utils/snackbar.dart';
import '../widgets/custom_progress_indicator.dart';
import '../services/firebase/firebase_auth_service.dart';
import 'forgot_password_prompt.dart';

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
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    } else if (!RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
        .hasMatch(value)) {
      return 'must contain uppercase, lowercase, number, special character.';
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
              screen: const HomeScreen(),
            );
          }
        } catch (e) {
          String errorMessage = 'An error occurred. Please try again later.';
          if (e is FirebaseAuthException) {
            switch (e.code) {
              case 'invalid-credential':
                errorMessage = 'Email or password is incorrect.';
                break;
              case 'invalid-email':
                errorMessage = 'Invalid email address.';
                break;
              case 'user-disabled':
                errorMessage = 'This account has been disabled.';
                break;
              case 'user-not-found':
                errorMessage = 'No user found with this email address.';
                break;
              case 'wrong-password':
                errorMessage = 'Incorrect password.';
                break;
              case 'too-many-requests':
                errorMessage =
                    'Too many unsuccessful login attempts. Please try again later.';
                break;
              case 'network-request-failed':
                errorMessage =
                    'Network error. Please check your internet connection.';
                break;
              case 'operation-not-allowed':
                errorMessage =
                    'Email/password sign-in is not allowed for this project.';
                break;
              default:
                errorMessage = 'An error occurred. Please try again later.';
                break;
            }
          }
          if (mounted) {
            buildFailureSnackbar(
              context: context,
              message: errorMessage,
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
          const SizedBox(height: 10.0),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ForgotPasswordPrompt(),
            ],
          ),
          const SizedBox(height: 10.0),
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
