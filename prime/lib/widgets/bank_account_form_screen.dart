import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bank_account.dart';
import '../providers/bank_account_provider.dart';
import '../services/firebase/firebase_auth_service.dart';
import '../widgets/custom_progress_indicator.dart';
import '../utils/snackbar.dart';

class BankAccountFormScreen extends StatefulWidget {
  final BankAccount? bankAccount;
  final bool isUpdate;

  const BankAccountFormScreen(
      {super.key, this.bankAccount, required this.isUpdate});

  @override
  State<BankAccountFormScreen> createState() => _BankAccountFormScreenState();
}

class _BankAccountFormScreenState extends State<BankAccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountHolderNameFocusNode = FocusNode();
  final _bankNameFocusNode = FocusNode();
  final _accountNumberFocusNode = FocusNode();

  final _accountHolderNameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();

  final _authService = FirebaseAuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate && widget.bankAccount != null) {
      _accountHolderNameController.text =
          widget.bankAccount?.accountHolderName ?? '';
      _bankNameController.text = widget.bankAccount?.bankName ?? '';
      _accountNumberController.text = widget.bankAccount!.accountNumber ?? '';
    }
  }

  @override
  void dispose() {
    _accountHolderNameFocusNode.dispose();
    _bankNameFocusNode.dispose();
    _accountNumberFocusNode.dispose();
    _accountHolderNameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  String? _validateAccountHolderName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the account holder name.';
    }
    return null;
  }

  String? _validateBankName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the bank name.';
    }
    return null;
  }

  String? _validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the account number.';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (mounted) {
      FocusScope.of(context).unfocus();
    }
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      final bankAccountProvider =
          Provider.of<BankAccountProvider>(context, listen: false);
      final hostId = _authService.currentUser?.uid ?? '';

      try {
        if (widget.isUpdate) {
          await bankAccountProvider.updateBankAccount(
            bankAccountId: widget.bankAccount?.id ?? '',
            accountHolderName: _accountHolderNameController.text.trim(),
            bankName: _bankNameController.text.trim(),
            accountNumber: _accountNumberController.text.trim(),
          );
        } else {
          await bankAccountProvider.createBankAccount(
            hostId: hostId,
            accountHolderName: _accountHolderNameController.text.trim(),
            bankName: _bankNameController.text.trim(),
            accountNumber: _accountNumberController.text.trim(),
          );
        }
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          buildSuccessSnackbar(
            context: context,
            message:
                'Bank account ${widget.isUpdate ? 'updated' : 'created'} successfully.',
          );
          Navigator.of(context).pop();
        }
      } on Exception catch (_) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          buildFailureSnackbar(
            context: context,
            message:
                'Error ${widget.isUpdate ? 'updating' : 'creating'} bank account. Please try again later.',
          );
        }
      } finally {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isUpdate ? 'Update Bank Account' : 'Add Bank Account'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                focusNode: _accountHolderNameFocusNode,
                textInputAction: TextInputAction.next,
                validator: _validateAccountHolderName,
                controller: _accountHolderNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: const Icon(Icons.person),
                  labelText: 'Account Holder Name',
                ),
                onFieldSubmitted: (_) {
                  _accountHolderNameFocusNode.unfocus();
                  if (mounted) {
                    FocusScope.of(context).requestFocus(_bankNameFocusNode);
                  }
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                focusNode: _bankNameFocusNode,
                textInputAction: TextInputAction.next,
                validator: _validateBankName,
                controller: _bankNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: const Icon(Icons.account_balance),
                  labelText: 'Bank Name',
                ),
                onFieldSubmitted: (_) {
                  _bankNameFocusNode.unfocus();
                  if (mounted) {
                    FocusScope.of(context)
                        .requestFocus(_accountNumberFocusNode);
                  }
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                focusNode: _accountNumberFocusNode,
                textInputAction: TextInputAction.done,
                validator: _validateAccountNumber,
                controller: _accountNumberController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: const Icon(Icons.credit_card),
                  labelText: 'Account Number',
                ),
                onFieldSubmitted: (_) {
                  _accountNumberFocusNode.unfocus();
                  _submitForm();
                },
              ),
              const Spacer(),
              SizedBox(
                height: 50.0,
                child: _isLoading
                    ? const CustomProgressIndicator()
                    : FilledButton(
                        onPressed: _submitForm,
                        child: Text(
                          widget.isUpdate
                              ? 'Update Bank Account'
                              : 'Add Bank Account',
                          style: const TextStyle(fontSize: 20),
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
