import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../services/firebase/firebase_auth_service.dart';
import '../../widgets/custom_progress_indicator.dart';
import '../../utils/snackbar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _phoneNumberFocusNode = FocusNode();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  final _authService = FirebaseAuthService();
  bool _updateProfileLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _loadUserProfile() async {
    try {
      final userInfo = await Provider.of<UserProvider>(context, listen: false)
          .getUserNameAndPhoneNo();
      if (userInfo.isNotEmpty) {
        setState(() {
          _firstNameController.text = userInfo['userFirstName'] ?? '';
          _lastNameController.text = userInfo['userLastName'] ?? '';
          _phoneNumberController.text = userInfo['userPhoneNumber'] ?? '';
        });
      } else {
        throw Exception();
      }
    } on Exception catch (e) {
      print('Error fetching user info: $e');
      if (mounted) {
        buildFailureSnackbar(
          context: context,
          message: 'Error fetching user info. Please try again.',
        );
      }
    }
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

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number.';
    }

    final RegExp phoneRegExp = RegExp(
        r'^\+?([0-9]{1,3})?-?([0-9]{1,4})?-?([0-9]{1,4})?-?([0-9]{1,4})$');

    if (!phoneRegExp.hasMatch(value)) {
      return 'Invalid contact number format.';
    }

    return null;
  }

  Future<void> _updateProfile() async {
    if (mounted) {
      FocusScope.of(context).unfocus();
    }
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      setState(() {
        _updateProfileLoading = true;
      });
      String firstName = _firstNameController.text.trim();
      String lastName = _lastNameController.text.trim();
      String phoneNumber = _phoneNumberController.text.trim();

      try {
        final userId = _authService.currentUser?.uid;

        if (userId != null) {
          await Provider.of<UserProvider>(context, listen: false)
              .updateUserProfile(
            userId: userId,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
          );
          setState(() {
            _updateProfileLoading = false;
          });
          if (mounted) {
            buildSuccessSnackbar(
              context: context,
              message: 'Profile updated successfully.',
            );
            Navigator.of(context).pop();
          }
        } else {
          if (mounted) {
            buildFailureSnackbar(
              context: context,
              message: 'Error updating profile. Please try again.',
            );
          }
        }
      } on Exception catch (_) {
        if (mounted) {
          buildFailureSnackbar(
            context: context,
            message: 'Error updating profile. Please try again.',
          );
        }
      } finally {
        setState(() {
          _updateProfileLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
                focusNode: _firstNameFocusNode,
                textInputAction: TextInputAction.next,
                validator: _validateFirstName,
                controller: _firstNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: const Icon(Icons.person),
                  labelText: 'First Name',
                ),
                onFieldSubmitted: (_) {
                  _firstNameFocusNode.unfocus();
                  if (mounted) {
                    FocusScope.of(context).requestFocus(_lastNameFocusNode);
                  }
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                focusNode: _lastNameFocusNode,
                textInputAction: TextInputAction.next,
                validator: _validateLastName,
                controller: _lastNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: const Icon(Icons.person),
                  labelText: 'Last Name',
                ),
                onFieldSubmitted: (_) {
                  _lastNameFocusNode.unfocus();
                  if (mounted) {
                    FocusScope.of(context).requestFocus(_phoneNumberFocusNode);
                  }
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                focusNode: _phoneNumberFocusNode,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.phone,
                validator: _validatePhoneNumber,
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                  labelText: 'Phone Number',
                ),
                onFieldSubmitted: (_) {
                  _phoneNumberFocusNode.unfocus();
                  _updateProfile();
                },
              ),
              const Spacer(),
              SizedBox(
                height: 50.0,
                child: _updateProfileLoading
                    ? const CustomProgressIndicator()
                    : FilledButton(
                        onPressed: _updateProfile,
                        child: const Text(
                          'Update Profile',
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
