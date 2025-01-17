import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../views/home/home_screen.dart';
import '../controllers/user_controller.dart';
import '../utils/navigate_with_animation.dart';
import '../controllers/customer_controller.dart';
import '../models/customer.dart';
import 'custom_progress_indicator.dart';
import '../utils/snackbar.dart';
import '../services/firebase/firebase_auth_service.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // bool _rememberMe = true;
  bool _signUpLoading = false;

  final _firebaseAuthService = FirebaseAuthService();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your first name.';
    }
    if (RegExp(r'[0-9]').hasMatch(value)) {
      return 'Numbers are not allowed in the first name.';
    }
    if (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]').hasMatch(value)) {
      return 'Special characters are not allowed in the first name.';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your last name.';
    }
    if (RegExp(r'[0-9]').hasMatch(value)) {
      return 'Numbers are not allowed in the last name.';
    }
    if (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]').hasMatch(value)) {
      return 'Special characters are not allowed in the last name.';
    }
    return null;
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

  Future<void> _signUp() async {
    if (mounted) {
      FocusScope.of(context).unfocus();
    }
    setState(() {
      _signUpLoading = true;
    });
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        try {
          // create a user
          final uid = await _firebaseAuthService.signUpWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          // create a customer using the user id
          final customerController = CustomerController();
          await customerController.createCustomer(
            customer: Customer(
              userId: uid,
              userEmail: _emailController.text.trim(),
              userFirstName: _firstNameController.text.trim(),
              userLastName: _lastNameController.text.trim(),
              userProfileUrl: UserController().defaultProfileUrl,
            ),
          );

          if (_formKey.currentState != null) {
            _formKey.currentState!.reset();
          }
          setState(() {
            _signUpLoading = false;
          });

          if (mounted) {
            // Display Confirmation Message
            buildSuccessSnackbar(
              context: context,
              message:
                  'Welcome aboard! Your account has been successfully created.',
            );

            animatedPushReplacementNavigation(
              context: context,
              screen: const HomeScreen(),
            );
          }
        } catch (e) {
          String errorMessage = 'Sign up failed. Please try again.';
          if (e is FirebaseAuthException) {
            switch (e.code) {
              case 'weak-password':
                errorMessage =
                    'Password is too weak. Please use a stronger password.';
                break;
              case 'email-already-in-use':
                errorMessage =
                    'This email is already in use. Please use a different email address.';
                break;
              case 'invalid-email':
                errorMessage = 'Invalid email address.';
                break;
              case 'operation-not-allowed':
                errorMessage =
                    'Email/password sign-up is not allowed for this project.';
                break;
              default:
                errorMessage = 'Sign up failed. Please try again.';
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
        _signUpLoading = false;
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
            focusNode: _firstNameFocusNode,
            textInputAction: TextInputAction.next,
            validator: _validateFirstName,
            onFieldSubmitted: (_) {
              _firstNameFocusNode.unfocus();
              FocusScope.of(context).requestFocus(_lastNameFocusNode);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              prefixIcon: const Icon(Icons.person),
              labelText: 'First Name',
            ),
            controller: _firstNameController,
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            focusNode: _lastNameFocusNode,
            textInputAction: TextInputAction.next,
            validator: _validateLastName,
            onFieldSubmitted: (_) {
              _lastNameFocusNode.unfocus();
              FocusScope.of(context).requestFocus(_emailFocusNode);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              prefixIcon: const Icon(Icons.person),
              labelText: 'Last Name',
            ),
            controller: _lastNameController,
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            focusNode: _emailFocusNode,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            onFieldSubmitted: (_) {
              _emailFocusNode.unfocus();
              FocusScope.of(context).requestFocus(_passwordFocusNode);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              prefixIcon: const Icon(Icons.email),
              labelText: 'Email',
            ),
            controller: _emailController,
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            focusNode: _passwordFocusNode,
            textInputAction: TextInputAction.done,
            obscureText: true,
            validator: _validatePassword,
            onFieldSubmitted: (_) {
              _passwordFocusNode.unfocus();
              _signUp();
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              prefixIcon: const Icon(Icons.lock),
              labelText: 'Password',
            ),
            controller: _passwordController,
          ),
          const SizedBox(height: 30.0),
          SizedBox(
            height: 50.0,
            child: _signUpLoading
                ? const CustomProgressIndicator()
                : FilledButton(
                    onPressed: _signUp,
                    child: const Text(
                      'Sign up',
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
