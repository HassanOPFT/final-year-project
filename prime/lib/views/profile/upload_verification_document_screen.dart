import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/services/firebase/firebase_auth_service.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_progress_indicator.dart';
import '../../models/verification_document.dart';
import '../../providers/customer_provider.dart';
import '../../providers/verification_document_provider.dart';
import '../../utils/snackbar.dart';
import '../../widgets/images/choose_image_container.dart';

class UploadVerificationDocumentScreen extends StatefulWidget {
  final String? linkedObjectId;
  final VerificationDocumentType verificationDocumentType;
  const UploadVerificationDocumentScreen({
    super.key,
    required this.linkedObjectId,
    required this.verificationDocumentType,
  });

  @override
  State<UploadVerificationDocumentScreen> createState() =>
      _UploadVerificationDocumentScreenState();
}

class _UploadVerificationDocumentScreenState
    extends State<UploadVerificationDocumentScreen> {
  late String appBarTitle;
  late String documentTitle;
  late String documentSubtitle;
  late String submitButtonText;

  File? _selectedImage;
  DateTime? _selectedDate;
  final _expiryDateController = TextEditingController();
  final _expiryDateFocusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    initializeDocumentDetails();
  }

  @override
  void dispose() {
    _expiryDateController.dispose();
    _expiryDateFocusNode.dispose();
    super.dispose();
  }

  void initializeDocumentDetails() {
    switch (widget.verificationDocumentType) {
      case VerificationDocumentType.identity:
        appBarTitle = 'Upload Identity Document';
        documentTitle = 'Upload a photo of your National ID Card or Passport';
        documentSubtitle =
            'Regulations require you to upload a national ID card or passport, including the expiry date. Don\'t worry, your data will stay safe and private.';
        submitButtonText = 'Submit Identity';
        break;
      case VerificationDocumentType.drivingLicense:
        appBarTitle = 'Upload Driving License';
        documentTitle = 'Upload your Driving License';
        documentSubtitle =
            'Please upload a clear photo of your driving license, including the expiry date. Make sure all details are visible.';
        submitButtonText = 'Submit Driving License';
        break;
      case VerificationDocumentType.carRegistration:
        appBarTitle = 'Upload Car Registration';
        documentTitle = 'Upload your Car Registration Document';
        documentSubtitle =
            'Please upload a clear photo of your car registration document, including the expiry date. Ensure all details are legible.';
        submitButtonText = 'Submit Car Registration';
        break;
      case VerificationDocumentType.carInsurance:
        appBarTitle = 'Upload Car Insurance';
        documentTitle = 'Upload your Car Insurance Document';
        documentSubtitle =
            'Please upload a clear photo of your car insurance document, including the expiry date. Ensure all details are visible.';
        submitButtonText = 'Submit Car Insurance';
        break;
      case VerificationDocumentType.carRoadTax:
        appBarTitle = 'Upload Car Road Tax';
        documentTitle = 'Upload your Car Road Tax Document';
        documentSubtitle =
            'Please upload a clear photo of your car road tax document, including the expiry date. Ensure all details are legible.';
        submitButtonText = 'Submit Car Road Tax';
        break;
    }
  }

  void setSelectedImage(File? image) {
    setState(() {
      _selectedImage = image;
    });
  }

  void setIsSubmitting(bool value) {
    setState(() {
      _isSubmitting = value;
    });
  }

  Future<void> uploadIdentityDocument() async {
    try {
      final verificationDocumentProvider =
          Provider.of<VerificationDocumentProvider>(
        context,
        listen: false,
      );
      // get the current user from firebase auth service
      final firebaseAuthService = FirebaseAuthService();
      if (firebaseAuthService.currentUser == null) {
        buildFailureSnackbar(
          context: context,
          message: 'Error while uploading Identity document. Please try again.',
        );
        return;
      }
      final currentUserId = firebaseAuthService.currentUser!.uid;
      final identityDocumentId =
          await verificationDocumentProvider.createVerificationDocument(
        widget.linkedObjectId,
        VerificationDocumentLinkedObjectType.user,
        widget.verificationDocumentType,
        _selectedDate,
        _selectedImage?.path,
        currentUserId,
      );
      if (identityDocumentId.isNotEmpty &&
          widget.linkedObjectId != null &&
          mounted) {
        final customerProvider = Provider.of<CustomerProvider>(
          context,
          listen: false,
        );
        await customerProvider.setIdentityDocumentId(
          userId: widget.linkedObjectId!,
          documentId: identityDocumentId,
        );
      }
      setIsSubmitting(false);
      if (mounted) {
        Navigator.of(context).pop();
        buildSuccessSnackbar(
          context: context,
          message: 'Identity document uploaded successfully',
        );
      }
    } on Exception catch (_) {
      setIsSubmitting(false);
      if (mounted) {
        buildFailureSnackbar(
          context: context,
          message: 'Error while uploading Identity document. Please try again.',
        );
      }
    }
  }

  Future<void> uploadDrivingLicense() async {
    try {
      final verificationDocumentProvider =
          Provider.of<VerificationDocumentProvider>(
        context,
        listen: false,
      );
      // get the current user from firebase auth service
      final firebaseAuthService = FirebaseAuthService();
      if (firebaseAuthService.currentUser == null) {
        buildFailureSnackbar(
          context: context,
          message: 'Error while driving license. Please try again.',
        );
        return;
      }
      final currentUserId = firebaseAuthService.currentUser!.uid;
      final drivingLicenseDocumentId =
          await verificationDocumentProvider.createVerificationDocument(
        widget.linkedObjectId,
        VerificationDocumentLinkedObjectType.user,
        widget.verificationDocumentType,
        _selectedDate,
        _selectedImage?.path,
        currentUserId,
      );
      if (drivingLicenseDocumentId.isNotEmpty &&
          widget.linkedObjectId != null &&
          mounted) {
        final customerProvider = Provider.of<CustomerProvider>(
          context,
          listen: false,
        );
        await customerProvider.setLicenseDocumentId(
          userId: widget.linkedObjectId!,
          documentId: drivingLicenseDocumentId,
        );
      }
      setIsSubmitting(false);
      if (mounted) {
        Navigator.of(context).pop();
        buildSuccessSnackbar(
          context: context,
          message: 'Driving license uploaded successfully',
        );
      }
    } on Exception catch (_) {
      setIsSubmitting(false);
      if (mounted) {
        buildFailureSnackbar(
          context: context,
          message: 'Error while uploading driving license. Please try again.',
        );
      }
    }
  }

  void uploadCarRegistration() {
    // TODO: implement this method
  }

  void uploadCarInsurance() {
    // TODO: implement this method
  }

  void uploadCarRoadTax() {
    // TODO: implement this method
  }

  void submitDocument() {
    _expiryDateFocusNode.unfocus();
    if (_selectedImage == null) {
      buildAlertSnackbar(
        context: context,
        message: 'Please select an image to upload',
      );
      return;
    }
    if (_selectedDate == null) {
      buildAlertSnackbar(
        context: context,
        message: 'Please select an expiry date for the document',
      );
      return;
    }
    if (widget.linkedObjectId == null) {
      buildAlertSnackbar(
        context: context,
        message: 'Something went wrong. Please try again.',
      );
      return;
    }
    setIsSubmitting(true);

    // Determine the document type based on verificationDocumentType
    switch (widget.verificationDocumentType) {
      case VerificationDocumentType.identity:
        uploadIdentityDocument();
        break;
      case VerificationDocumentType.drivingLicense:
        uploadDrivingLicense();
        break;
      case VerificationDocumentType.carRegistration:
        uploadCarRegistration();
        break;
      case VerificationDocumentType.carInsurance:
        uploadCarInsurance();
        break;
      case VerificationDocumentType.carRoadTax:
        uploadCarRoadTax();
        break;
      default:
        setIsSubmitting(false);
        buildFailureSnackbar(
          context: context,
          message: 'Something went wrong. Please try again.',
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          20.0,
          20.0,
          20.0,
          MediaQuery.of(context).padding.bottom + 20.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      documentTitle,
                      style: const TextStyle(
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      documentSubtitle,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    ChooseImageContainer(setSelectedImage: setSelectedImage),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: _expiryDateController,
                      decoration: InputDecoration(
                        labelText: 'Expiry Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today_rounded),
                        hintText: 'MM/DD/YY',
                      ),
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != _selectedDate) {
                          setState(() {
                            _selectedDate = picked;
                            _expiryDateController.text =
                                DateFormat.yMd().format(picked);
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an expiry date';
                        }
                        if (_selectedDate != null &&
                            _selectedDate!.isBefore(DateTime.now())) {
                          return 'Expiry date cannot be in the past';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              height: 50.0,
              child: _isSubmitting
                  ? const CustomProgressIndicator()
                  : FilledButton(
                      onPressed:
                          submitDocument, // Disable button if no file is selected
                      child: Text(
                        submitButtonText,
                        style: const TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
