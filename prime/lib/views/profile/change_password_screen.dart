import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/firebase/firebase_auth_service.dart';
import '../../widgets/custom_progress_indicator.dart';
import '../../utils/snackbar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _newPasswordFocusNode = FocusNode();
  final _reEnterPasswordFocusNode = FocusNode();

  final _newPasswordController = TextEditingController();
  final _reEnterPasswordController = TextEditingController();

  final _authService = FirebaseAuthService();
  bool _updatePasswordLoading = false;

  @override
  void dispose() {
    _newPasswordFocusNode.dispose();
    _reEnterPasswordFocusNode.dispose();
    _newPasswordController.dispose();
    _reEnterPasswordController.dispose();
    super.dispose();
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

  String? _validateReEnteredPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please re-enter your new password.';
    } else if (value != _newPasswordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  Future<void> _updatePassword() async {
    if (mounted) {
      FocusScope.of(context).unfocus();
    }
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      setState(() {
        _updatePasswordLoading = true;
      });

      String newPassword = _newPasswordController.text.trim();

      try {
        await _authService.updatePassword(newPassword);
        setState(() {
          _updatePasswordLoading = false;
        });
        if (mounted) {
          buildSuccessSnackbar(
            context: context,
            message: 'Password updated successfully.',
          );
          Navigator.of(context).pop();
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _updatePasswordLoading = false;
        });
        if (e.code == 'weak-password') {
          if (mounted) {
            buildFailureSnackbar(
              context: context,
              message: 'Password is not strong enough. Please try again.',
            );
          }
        } else if (e.code == 'requires-recent-login') {
          if (mounted) {
            buildFailureSnackbar(
              context: context,
              message: 'Please sign in again to update your password.',
            );
          }
        } else {
          if (mounted) {
            buildFailureSnackbar(
              context: context,
              message: 'Error updating password. Please try again.',
            );
          }
        }
      } on Exception catch (_) {
        setState(() {
          _updatePasswordLoading = false;
        });
        if (mounted) {
          buildFailureSnackbar(
            context: context,
            message: 'Error updating password. Please try again.',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                focusNode: _newPasswordFocusNode,
                textInputAction: TextInputAction.next,
                validator: _validatePassword,
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  labelText: 'New Password',
                ),
                onFieldSubmitted: (_) {
                  _newPasswordFocusNode.unfocus();
                  FocusScope.of(context)
                      .requestFocus(_reEnterPasswordFocusNode);
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                focusNode: _reEnterPasswordFocusNode,
                textInputAction: TextInputAction.done,
                validator: _validateReEnteredPassword,
                controller: _reEnterPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  labelText: 'Re-enter New Password',
                ),
                onFieldSubmitted: (_) {
                  _reEnterPasswordFocusNode.unfocus();
                  _updatePassword();
                },
              ),
              const Spacer(),
              SizedBox(
                height: 50.0,
                child: _updatePasswordLoading
                    ? const CustomProgressIndicator()
                    : FilledButton(
                        onPressed: _updatePassword,
                        child: const Text(
                          'Update Password',
                          style: TextStyle(
                            fontSize: 20,
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
