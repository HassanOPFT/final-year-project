// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prime/controllers/user_controller.dart';
import 'package:prime/models/admin.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';
import 'package:prime/utils/snackbar.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../services/firebase/firebase_auth_service.dart';
import '../../services/firebase/firebase_cloud_functions_service.dart';
import '../../utils/generate_reference_number.dart';

class CreateAdminScreen extends StatefulWidget {
  const CreateAdminScreen({super.key});

  @override
  State<CreateAdminScreen> createState() => _CreateAdminScreenState();
}

class _CreateAdminScreenState extends State<CreateAdminScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _createAdminLoading = false;

  final _firebaseAuthService = FirebaseAuthService();

  @override
  void dispose() {
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a first name.';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a last name.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address.';
    } else if (!RegExp(
            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*")
        .hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  Future<void> _createAdmin() async {
    // unfocus the keyboard if still visible
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _createAdminLoading = true;
      });

      try {
        final userEmail = _emailController.text.trim();
        final userPassword = _passwordController.text.trim();
        final userFirstName = _firstNameController.text.trim();
        final userLastName = _lastNameController.text.trim();

        final firebaseCloudFunctionsService = FirebaseCloudFunctionsService();

        final newSecondaryAdminId =
            await firebaseCloudFunctionsService.createUser(
          email: userEmail,
          password: userPassword,
          displayName: '$userFirstName $userLastName',
        );

        final userProvider = Provider.of<UserProvider>(
          context,
          listen: false,
        );

        final newSecondaryAdmin = Admin(
          userId: newSecondaryAdminId,
          userFirstName: _firstNameController.text.trim(),
          userLastName: _lastNameController.text.trim(),
          userEmail: userEmail,
          userRole: UserRole.secondaryAdmin,
          userReferenceNumber: generateReferenceNumber('ADM'),
          userProfileUrl: UserController().defaultProfileUrl,
          userPhoneNumber: '',
          userFcmToken: '',
          userActivityStatus: ActivityStatus.active,
          notificationsEnabled: true,
        );

        await userProvider.createUser(
          user: newSecondaryAdmin,
        );

        _emailController.clear();
        _passwordController.clear();

        setState(() {
          _createAdminLoading = false;
        });

        if (mounted) {
          Navigator.of(context).pop();
        }

        buildSuccessSnackbar(
          context: context,
          message: 'Secondary Admin created successfully.',
        );
      } catch (e) {
        debugPrint('#' * 25);
        debugPrint('Error creating secondary admin: $e');
        debugPrint('#' * 25);
        setState(() {
          _createAdminLoading = false;
        });
        String errorMessage = 'An error occurred. Please try again later.';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = 'This email is already registered.';
              break;
            default:
              errorMessage = 'An error occurred. Please try again later.';
              break;
          }
        }

        buildFailureSnackbar(
          context: context,
          message: errorMessage,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
                enabled: false,
                initialValue: UserRole.secondaryAdmin.toReadableString(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: const Icon(Icons.security),
                  labelText: 'User Role',
                ),
              ),
              const SizedBox(height: 20.0),
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
                  _createAdmin();
                },
              ),
              const Spacer(),
              SizedBox(
                height: 50.0,
                child: _createAdminLoading
                    ? const CustomProgressIndicator()
                    : FilledButton(
                        onPressed: _createAdmin,
                        child: const Text(
                          'Create Admin',
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
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
