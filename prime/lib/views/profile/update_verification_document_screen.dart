// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/car.dart';
import '../../models/verification_document.dart';
import '../../providers/car_provider.dart';
import '../../providers/status_history_provider.dart';
import '../../providers/verification_document_provider.dart';
import '../../services/firebase/firebase_auth_service.dart';
import '../../utils/navigate_with_animation.dart';
import '../../utils/snackbar.dart';
import '../../widgets/images/choose_image_container.dart';
import '../../widgets/custom_progress_indicator.dart';
import 'view_full_image_screen.dart';

class UpdateVerificationDocumentScreen extends StatefulWidget {
  final VerificationDocument verificationDocument;
  const UpdateVerificationDocumentScreen({
    super.key,
    required this.verificationDocument,
  });

  @override
  State<UpdateVerificationDocumentScreen> createState() =>
      _UpdateVerificationDocumentScreenState();
}

class _UpdateVerificationDocumentScreenState
    extends State<UpdateVerificationDocumentScreen> {
  late String appBarTitle;
  late String documentTitle;
  late String documentSubtitle;
  late String submitButtonText;

  File? _selectedImage;
  DateTime? _selectedDate;
  final _expiryDateController = TextEditingController();
  final _expiryDateFocusNode = FocusNode();
  bool _isSubmitting = false;
  bool changeDocument = false;

  @override
  void initState() {
    super.initState();
    initializeDocumentDetails();
    // Initialize the expiry date field with the existing date
    if (widget.verificationDocument.expiryDate != null) {
      _selectedDate = widget.verificationDocument.expiryDate;
      _expiryDateController.text = DateFormat.yMd()
          .format(widget.verificationDocument.expiryDate as DateTime);
    }
  }

  @override
  void dispose() {
    _expiryDateController.dispose();
    _expiryDateFocusNode.dispose();
    super.dispose();
  }

  void initializeDocumentDetails() {
    switch (widget.verificationDocument.documentType) {
      case VerificationDocumentType.identity:
        appBarTitle = 'Update Identity Document';
        documentTitle = 'Update your National ID Card or Passport';
        documentSubtitle =
            'Regulations require you to upload a national ID card or passport, including the expiry date. Don\'t worry, your data will stay safe and private.';
        submitButtonText = 'Update Identity';
        break;
      case VerificationDocumentType.drivingLicense:
        appBarTitle = 'Update Driving License';
        documentTitle = 'Update your Driving License';
        documentSubtitle =
            'Please upload a clear photo of your driving license, including the expiry date. Make sure all details are visible.';
        submitButtonText = 'Update Driving License';
        break;
      case VerificationDocumentType.carRegistration:
        appBarTitle = 'Update Car Registration';
        documentTitle = 'Update your Car Registration Document';
        documentSubtitle =
            'Please upload a clear photo of your car registration document, including the expiry date. Ensure all details are legible.';
        submitButtonText = 'Update Car Registration';
        break;
      case VerificationDocumentType.carInsurance:
        appBarTitle = 'Update Car Insurance';
        documentTitle = 'Update your Car Insurance Document';
        documentSubtitle =
            'Please upload a clear photo of your car insurance document, including the expiry date. Ensure all details are visible.';
        submitButtonText = 'Update Car Insurance';
        break;
      case VerificationDocumentType.carRoadTax:
        appBarTitle = 'Update Car Road Tax';
        documentTitle = 'Update your Car Road Tax Document';
        documentSubtitle =
            'Please upload a clear photo of your car road tax document, including the expiry date. Ensure all details are legible.';
        submitButtonText = 'Update Car Road Tax';
        break;
      default:
        appBarTitle = 'Update Document';
        documentTitle = 'Update Document';
        documentSubtitle = 'Please update the document';
        submitButtonText = 'Update Document';
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

  void setChangeDocument(bool value) {
    setState(() {
      changeDocument = value;
    });
  }

  Future<void> _updateDocument() async {
    if (_selectedDate == null) {
      buildAlertSnackbar(
        context: context,
        message: 'Please select an expiry date for the document',
      );
      return;
    }

    if (changeDocument) {
      if (_selectedImage == null) {
        buildAlertSnackbar(
          context: context,
          message: 'Please select new image to upload',
        );
        return;
      }
    } else {
      if (_selectedDate == widget.verificationDocument.expiryDate) {
        buildAlertSnackbar(
          context: context,
          message:
              'Please select a new image or expiry date to update the document',
        );
        return;
      }
    }

    setIsSubmitting(true);

    try {
      if (widget.verificationDocument.id == null ||
          widget.verificationDocument.id!.isEmpty) {
        throw Exception('Document ID is missing');
      }

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

      await verificationDocumentProvider.updateVerificationDocument(
        verificationDocumentId: widget.verificationDocument.id as String,
        changeDocument: changeDocument,
        expiryDate: _selectedDate as DateTime,
        previousStatus:
            widget.verificationDocument.status as VerificationDocumentStatus,
        newStatus: VerificationDocumentStatus.updated,
        verificationDocumentReferenceNumber:
            widget.verificationDocument.referenceNumber as String,
        documentType: widget.verificationDocument.documentType
            as VerificationDocumentType,
        filePath: _selectedImage?.path ?? '',
        verificationDocumentUrl: widget.verificationDocument.documentUrl,
        modifiedById: currentUserId,
      );
      if (widget.verificationDocument.linkedObjectType ==
          VerificationDocumentLinkedObjectType.car) {
        // update car status
        final carProvider = Provider.of<CarProvider>(
          context,
          listen: false,
        );
        await carProvider.updateCarStatus(
          carId: widget.verificationDocument.linkedObjectId ?? '',
          previousStatus: CarStatus.updated,
          newStatus: CarStatus.updated,
          modifiedById: currentUserId,
          statusDescription: '',
        );
      }

      Provider.of<StatusHistoryProvider>(
        context,
        listen: false,
      ).notify();

      setIsSubmitting(false);
      if (mounted) {
        Navigator.of(context).pop();
        buildSuccessSnackbar(
          context: context,
          message: 'Document updated successfully.',
        );
      }
    } catch (e) {
      debugPrint('#' * 25);
      debugPrint('Error while updating document: $e');
      debugPrint('#' * 25);
      if (mounted) {
        setIsSubmitting(false);
        buildFailureSnackbar(
          context: context,
          message: 'Error while uploading document. Please try again.',
        );
      }
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      documentTitle,
                      style: const TextStyle(
                        fontSize: 32.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(documentSubtitle),
                    const SizedBox(height: 20.0),
                    if (changeDocument)
                      ChooseImageContainer(
                        setSelectedImage: setSelectedImage,
                      ),
                    if (!changeDocument)
                      GestureDetector(
                        onTap: widget.verificationDocument.documentUrl != null
                            ? () => animatedPushNavigation(
                                  context: context,
                                  screen: ViewFullImageScreen(
                                    imageUrl: widget
                                        .verificationDocument.documentUrl!,
                                    appBarTitle: 'Document Image',
                                    tag: 'document-image',
                                  ),
                                )
                            : null,
                        child: Hero(
                          tag: 'document-image',
                          child: Container(
                            width: double.infinity,
                            height: 200.0,
                            decoration:
                                widget.verificationDocument.documentUrl == null
                                    ? null
                                    : BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        image: DecorationImage(
                                          image: NetworkImage(widget
                                              .verificationDocument
                                              .documentUrl!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                            // display a placeholder image if documentUrl is null
                            child:
                                widget.verificationDocument.documentUrl == null
                                    ? const Center(
                                        child: Text('Error loading image'),
                                      )
                                    : null,
                          ),
                        ),
                      ),
                    if (!changeDocument)
                      TextButton.icon(
                        onPressed: () => setChangeDocument(true),
                        icon: const Icon(Icons.change_circle_rounded),
                        label: const Text(
                          'Change',
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      ),
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
                          _updateDocument,
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
