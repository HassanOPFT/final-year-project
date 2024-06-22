// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/models/status_history.dart';
import 'package:prime/widgets/latest_status_history_record.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/car.dart';
import '../../providers/car_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/status_history_provider.dart';
import '../../utils/assets_paths.dart';
import '../../utils/snackbar.dart';
import '../../widgets/created_at_row.dart';
import '../../widgets/custom_progress_indicator.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../providers/verification_document_provider.dart';
import '../../services/firebase/firebase_auth_service.dart';
import '../../utils/navigate_with_animation.dart';
import '../../widgets/reference_number_row.dart';
import 'update_verification_document_screen.dart';
import 'view_full_image_screen.dart';
import '../../models/verification_document.dart';
import '../../widgets/bottom_sheet/edit_verification_document_bottom_sheet.dart';
import '../../widgets/verification_document_status_indicator.dart';

class VerificationDocumentDetailsScreen extends StatelessWidget {
  final String verificationDocumentId;

  const VerificationDocumentDetailsScreen({
    super.key,
    required this.verificationDocumentId,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final userRole = userProvider.user?.userRole ?? UserRole.customer;
    final firebaseAuthService = FirebaseAuthService();
    final verificationDocumentProvider =
        Provider.of<VerificationDocumentProvider>(
      context,
    );

    void updateVerificationDocument(VerificationDocument verificationDocument) {
      animatedPushNavigation(
        context: context,
        screen: UpdateVerificationDocumentScreen(
          verificationDocument: verificationDocument,
        ),
      );
    }

    Future<void> approveVerificationDocument(
        VerificationDocument verificationDocument) async {
      if (verificationDocument.id == null || verificationDocument.id!.isEmpty) {
        return;
      }
      if (firebaseAuthService.currentUser == null) {
        buildFailureSnackbar(
          context: context,
          message: 'Error while approving document. Please try again.',
        );
        return;
      }

      try {
        final currentUserId = firebaseAuthService.currentUser!.uid;
        await verificationDocumentProvider.updateVerificationDocumentStatus(
          verificationDocumentId: verificationDocument.id!,
          newStatus: VerificationDocumentStatus.approved,
          previousStatus:
              verificationDocument.status as VerificationDocumentStatus,
          documentType:
              verificationDocument.documentType as VerificationDocumentType,
          modifiedById: currentUserId,
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Document approved successfully',
        );
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error approving document. Please try again later.',
        );
      }
    }

    Future<String?> showReasonDialog({
      required String title,
      required String hintText,
    }) async {
      final TextEditingController reasonController = TextEditingController();
      final formKey = GlobalKey<FormState>();

      return showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(title),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: reasonController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        labelText: hintText,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().isEmpty) {
                          return 'Please enter a reason.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        if (formKey.currentState!.validate()) {
                          Navigator.of(context).pop(reasonController.text);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop(reasonController.text);
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );
    }

    Future<void> rejectVerificationDocument(
      VerificationDocument verificationDocument,
    ) async {
      if (verificationDocument.id == null || verificationDocument.id!.isEmpty) {
        return;
      }

      if (firebaseAuthService.currentUser == null) {
        buildFailureSnackbar(
          context: context,
          message: 'Error while rejecting document. Please try again.',
        );
        return;
      }

      String? rejectReason = await showReasonDialog(
        title: 'Rejection Reason',
        hintText: 'Enter reason for rejection',
      );

      if (rejectReason == null) {
        return;
      }

      if (rejectReason.isEmpty) {
        buildAlertSnackbar(
          context: context,
          message:
              'Reason for rejection is required to reject document. please try again.',
        );
        return;
      }

      try {
        final currentUserId = firebaseAuthService.currentUser!.uid;
        await verificationDocumentProvider.updateVerificationDocumentStatus(
          verificationDocumentId: verificationDocument.id!,
          newStatus: VerificationDocumentStatus.rejected,
          previousStatus:
              verificationDocument.status as VerificationDocumentStatus,
          statusDescription: rejectReason,
          documentType:
              verificationDocument.documentType as VerificationDocumentType,
          modifiedById: currentUserId,
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Document rejected successfully',
        );
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error rejecting document. Please try again later.',
        );
      }
    }

    Future<void> haltVerificationDocument(
      VerificationDocument verificationDocument,
    ) async {
      if (verificationDocument.id == null || verificationDocument.id!.isEmpty) {
        return;
      }

      String? haltReason = await showReasonDialog(
        title: 'Halt Reason',
        hintText: 'Enter reason for halting',
      );

      if (haltReason == null) {
        return;
      }

      if (haltReason.isEmpty) {
        buildFailureSnackbar(
          context: context,
          message:
              'Reason for halting is required to halt document. please try again.',
        );
        return;
      }

      try {
        final firebaseAuthService = FirebaseAuthService();
        if (firebaseAuthService.currentUser == null) {
          buildFailureSnackbar(
            context: context,
            message: 'Error while halting document. Please try again.',
          );
          return;
        }
        final currentUserId = firebaseAuthService.currentUser!.uid;
        await verificationDocumentProvider.updateVerificationDocumentStatus(
          verificationDocumentId: verificationDocument.id!,
          newStatus: VerificationDocumentStatus.halted,
          previousStatus:
              verificationDocument.status as VerificationDocumentStatus,
          statusDescription: haltReason,
          documentType:
              verificationDocument.documentType as VerificationDocumentType,
          modifiedById: currentUserId,
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Document halted successfully',
        );
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error halting document. Please try again later.',
        );
      }
    }

    Future<void> requestUnhaltVerificationDocument(
      VerificationDocument verificationDocument,
    ) async {
      if (verificationDocument.id == null || verificationDocument.id!.isEmpty) {
        return;
      }

      try {
        final firebaseAuthService = FirebaseAuthService();
        if (firebaseAuthService.currentUser == null) {
          buildFailureSnackbar(
            context: context,
            message: 'Error while requesting unhalt. Please try again.',
          );
          return;
        }
        final currentUserId = firebaseAuthService.currentUser!.uid;
        await verificationDocumentProvider.updateVerificationDocumentStatus(
          verificationDocumentId: verificationDocument.id!,
          newStatus: VerificationDocumentStatus.unHaltRequested,
          previousStatus:
              verificationDocument.status as VerificationDocumentStatus,
          documentType:
              verificationDocument.documentType as VerificationDocumentType,
          modifiedById: currentUserId,
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Unhalt requested successfully',
        );
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error requesting unhalt. Please try again later.',
        );
      }
    }

    Future<void> unhaltVerificationDocument(
      VerificationDocument verificationDocument,
    ) async {
      if (verificationDocument.id == null || verificationDocument.id!.isEmpty) {
        return;
      }

      try {
        final firebaseAuthService = FirebaseAuthService();
        if (firebaseAuthService.currentUser == null) {
          buildFailureSnackbar(
            context: context,
            message: 'Error while un-halting document. Please try again.',
          );
          return;
        }
        final currentUserId = firebaseAuthService.currentUser!.uid;
        await verificationDocumentProvider.updateVerificationDocumentStatus(
          verificationDocumentId: verificationDocument.id!,
          newStatus: VerificationDocumentStatus.pendingApproval,
          previousStatus:
              verificationDocument.status as VerificationDocumentStatus,
          documentType:
              verificationDocument.documentType as VerificationDocumentType,
          modifiedById: currentUserId,
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Document un-halted successfully',
        );
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error un-halting document. Please try again later.',
        );
      }
    }

    Future<bool> confirmDeleteDocument(BuildContext context) async {
      bool isConfirmed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AssetsPaths.binImage,
                  height: 200.0,
                ),
                const Text(
                  'Are you sure you want to delete this document? This action cannot be undone.',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      return isConfirmed;
    }

    Future<void> deleteVerificationDocument(
      VerificationDocument verificationDocument,
    ) async {
      if (verificationDocument.id == null || verificationDocument.id!.isEmpty) {
        return;
      }

      bool confirmDeletion = await confirmDeleteDocument(context);
      if (!confirmDeletion) {
        return;
      }
      final verificationDocumentProvider =
          Provider.of<VerificationDocumentProvider>(
        context,
        listen: false,
      );

      try {
        final firebaseAuthService = FirebaseAuthService();
        if (firebaseAuthService.currentUser == null) {
          buildFailureSnackbar(
            context: context,
            message:
                'Error while uploading Identity document. Please try again.',
          );
          return;
        }
        final currentUserId = firebaseAuthService.currentUser!.uid;
        await verificationDocumentProvider.deleteVerificationDocument(
          documentId: verificationDocument.id!,
          referenceNumber: verificationDocument.referenceNumber ?? '',
          documentType:
              verificationDocument.documentType as VerificationDocumentType,
          userRole: userRole,
          previousStatus:
              verificationDocument.status as VerificationDocumentStatus,
          modifiedById: currentUserId,
        );
        // update car status
        if (verificationDocument.linkedObjectType ==
            VerificationDocumentLinkedObjectType.car) {
          final carProvider = Provider.of<CarProvider>(
            context,
            listen: false,
          );
          await carProvider.updateCarStatus(
            carId: verificationDocument.linkedObjectId ?? '',
            previousStatus: CarStatus.updated,
            newStatus: CarStatus.updated,
            modifiedById: currentUserId,
            statusDescription: '',
          );
          // delete the document id from the object
          if (verificationDocument.documentType ==
              VerificationDocumentType.carInsurance) {
            await carProvider.deleteCarInsuranceDocument(
              carId: verificationDocument.linkedObjectId ?? '',
            );
          } else if (verificationDocument.documentType ==
              VerificationDocumentType.carRegistration) {
            await carProvider.deleteCarRegistrationDocument(
              carId: verificationDocument.linkedObjectId ?? '',
            );
          } else if (verificationDocument.documentType ==
              VerificationDocumentType.carRoadTax) {
            await carProvider.deleteCarRoadTaxDocument(
              carId: verificationDocument.linkedObjectId ?? '',
            );
          } else if (verificationDocument.documentType ==
              VerificationDocumentType.identity) {
            final customerProvider = Provider.of<CustomerProvider>(
              context,
              listen: false,
            );
            await customerProvider.deleteIdentityDocumentId(
              verificationDocument.linkedObjectId ?? '',
            );
          } else if (verificationDocument.documentType ==
              VerificationDocumentType.drivingLicense) {
            final customerProvider = Provider.of<CustomerProvider>(
              context,
              listen: false,
            );
            await customerProvider.deleteLicenseDocumentId(
              verificationDocument.linkedObjectId ?? '',
            );
          }
        }
        // call notify of status history provider
        Provider.of<StatusHistoryProvider>(
          context,
          listen: false,
        ).notify();

        buildSuccessSnackbar(
          context: context,
          message: 'Document deleted successfully',
        );
        Navigator.of(context).pop();
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error deleting document. Please try again later.',
        );
      }
    }

    Future<void> showEditVerificationDocumentBottomSheet(
      VerificationDocument verificationDocument,
    ) async {
      await showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (BuildContext context) {
          return EditVerificationDocumentBottomSheet(
            updateVerificationDocument: updateVerificationDocument,
            deleteVerificationDocument: deleteVerificationDocument,
            approveVerificationDocument: approveVerificationDocument,
            rejectVerificationDocument: rejectVerificationDocument,
            haltVerificationDocument: haltVerificationDocument,
            requestUnhaltVerificationDocument:
                requestUnhaltVerificationDocument,
            unhaltVerificationDocument: unhaltVerificationDocument,
            isAdmin: userRole == UserRole.primaryAdmin ||
                userRole == UserRole.secondaryAdmin,
            documentStatus:
                verificationDocument.status as VerificationDocumentStatus,
            verificationDocument: verificationDocument,
          );
        },
      );
    }

    Future<StatusHistory?> getMostRecentStatusHistory(
      String? verificationDocumentId,
    ) async {
      if (verificationDocumentId == null || verificationDocumentId.isEmpty) {
        return null;
      }
      try {
        final statusHistoryProvider = Provider.of<StatusHistoryProvider>(
          context,
        );
        final mostRecentStatusHistory =
            await statusHistoryProvider.getMostRecentStatusHistory(
          verificationDocumentId,
        );
        return mostRecentStatusHistory;
      } catch (_) {
        return null;
      }
    }

    return FutureBuilder<VerificationDocument?>(
      future: verificationDocumentProvider
          .getVerificationDocumentById(verificationDocumentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Document Details'),
            ),
            body: const Center(
              child: CustomProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Document Details'),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            body: Scaffold(
              appBar: AppBar(
                title: const Text('Document Details'),
              ),
              body: const Center(
                child: Text('No verification document found.'),
              ),
            ),
          );
        } else {
          final verificationDocument = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                '${verificationDocument.documentType?.getDocumentTypeString()} Details',
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => showEditVerificationDocumentBottomSheet(
                    verificationDocument,
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: verificationDocument.documentUrl != null
                              ? () => animatedPushNavigation(
                                    context: context,
                                    screen: ViewFullImageScreen(
                                      imageUrl:
                                          verificationDocument.documentUrl!,
                                      appBarTitle: 'Document Image',
                                      tag: 'document-image',
                                    ),
                                  )
                              : null,
                          child: Hero(
                            tag: 'document-image',
                            child: SizedBox(
                              width: double.infinity,
                              height: 250,
                              child: verificationDocument.documentUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            verificationDocument.documentUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const CustomProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            const Center(
                                                child: Icon(Icons.error)),
                                      ),
                                    )
                                  : const Center(
                                      child: Text('Error loading image'),
                                    ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10.0,
                          right: 10.0,
                          child: Consumer<VerificationDocumentProvider>(
                            builder: (BuildContext context,
                                VerificationDocumentProvider value,
                                Widget? child) {
                              return VerificationDocumentStatusIndicator(
                                verificationDocumentStatus: verificationDocument
                                    .status as VerificationDocumentStatus,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Expires on',
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: 20.0,
                          ),
                        ),
                        Text(
                          verificationDocument.expiryDate != null
                              ? DateFormat.yMMMMd().format(
                                  verificationDocument.expiryDate as DateTime)
                              : 'N/A',
                          style: const TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15.0),
                    LatestStatusHistoryRecord(
                      fetchStatusHistory: getMostRecentStatusHistory,
                      linkedObjectId:
                          verificationDocument.id ?? verificationDocumentId,
                    ),
                    const SizedBox(height: 15.0),
                    const Divider(thickness: 0.3),
                    const SizedBox(height: 15.0),
                    ReferenceNumberRow(
                      referenceNumber: verificationDocument.referenceNumber,
                    ),
                    const SizedBox(height: 10.0),
                    CreatedAtRow(
                      labelText: 'Added On',
                      createdAt: verificationDocument.createdAt,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
