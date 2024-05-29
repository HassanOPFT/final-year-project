// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:prime/services/firebase/firebase_auth_service.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/views/cars/edit_host_car_screen.dart';
import 'package:provider/provider.dart';
import '../../models/car.dart';
import '../../models/user.dart';
import '../../models/verification_document.dart';
import '../../providers/car_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/verification_document_provider.dart';
import '../../utils/assets_paths.dart';
import '../../utils/snackbar.dart';

class EditCarBottomSheet extends StatelessWidget {
  final bool isAdmin;
  final Car car;

  const EditCarBottomSheet({
    super.key,
    required this.isAdmin,
    required this.car,
  });

  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(
      context,
      listen: false,
    );
    final currentUserId = FirebaseAuthService().currentUser?.uid ?? '';
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    void updateCar() {
      Navigator.of(context).pop();
      animatedPushNavigation(
        context: context,
        screen: EditHostCarScreen(car: car),
      );
    }

    Future<bool> confirmDeleteCar() async {
      bool isConfirmed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AssetsPaths.binImage, // Change to your bin image path
                  height: 200.0,
                ),
                const Text(
                  'Are you sure you want to delete this car? This action cannot be undone.',
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

    Future<void> deleteCar() async {
      Navigator.of(context).pop();
      bool confirmDeletion = await confirmDeleteCar();
      if (!confirmDeletion) {
        return;
      }

      try {
        if (currentUserId.isEmpty || car.id != null || car.id!.isEmpty) {
          throw Exception('Current user id is empty');
        }

        final currentUserRole = await userProvider.getUserRole(currentUserId);
        final bool isAdmin = currentUserRole == UserRole.primaryAdmin ||
            currentUserRole == UserRole.secondaryAdmin;

        // delete car
        await carProvider.deleteCar(
          carId: car.id ?? '',
          isAdmin: isAdmin,
          modifiedById: currentUserId,
        );

        if (isAdmin) {
          // delete associated address
          final verificationDocumentProvider =
              Provider.of<VerificationDocumentProvider>(
            context,
            listen: false,
          );

          // delete car registration document
          final registrationDocument =
              await verificationDocumentProvider.getVerificationDocumentById(
            car.registrationDocumentId ?? '',
          );
          await verificationDocumentProvider.deleteVerificationDocument(
            documentId: car.registrationDocumentId ?? '',
            referenceNumber: registrationDocument?.referenceNumber ?? '',
            documentType:
                registrationDocument?.documentType as VerificationDocumentType,
            userRole: currentUserRole,
            previousStatus:
                registrationDocument?.status as VerificationDocumentStatus,
            modifiedById: currentUserId,
          );
          // delete car road tax document
          final roadTaxDocument =
              await verificationDocumentProvider.getVerificationDocumentById(
            car.roadTaxDocumentId ?? '',
          );
          await verificationDocumentProvider.deleteVerificationDocument(
            documentId: car.roadTaxDocumentId ?? '',
            referenceNumber: roadTaxDocument?.referenceNumber ?? '',
            documentType:
                roadTaxDocument?.documentType as VerificationDocumentType,
            userRole: currentUserRole,
            previousStatus:
                roadTaxDocument?.status as VerificationDocumentStatus,
            modifiedById: currentUserId,
          );
          // delete car insurance document
          final insuranceDocument =
              await verificationDocumentProvider.getVerificationDocumentById(
            car.insuranceDocumentId ?? '',
          );
          await verificationDocumentProvider.deleteVerificationDocument(
            documentId: car.insuranceDocumentId ?? '',
            referenceNumber: insuranceDocument?.referenceNumber ?? '',
            documentType:
                insuranceDocument?.documentType as VerificationDocumentType,
            userRole: currentUserRole,
            previousStatus:
                insuranceDocument?.status as VerificationDocumentStatus,
            modifiedById: currentUserId,
          );
        }
        buildSuccessSnackbar(
          context: context,
          message: 'Car deleted successfully.',
        );
      } catch (_) {
        // Close the loading dialog
        Navigator.of(context, rootNavigator: true).pop();
        buildFailureSnackbar(
          context: context,
          message: 'Error deleting car. Please try again later.',
        );
      }
    }

    Future<void> approveCar() async {
      Navigator.of(context).pop();
      try {
        await carProvider.updateCarStatus(
          carId: car.id ?? '',
          previousStatus: car.status as CarStatus,
          newStatus: CarStatus.approved,
          modifiedById: currentUserId,
          statusDescription: '',
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Car approved successfully.',
        );
      } catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error approving car. Please try again later.',
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
              width: MediaQuery.of(context).size.width, // Set the width
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

    Future<void> rejectCar() async {
      Navigator.of(context).pop();
      final rejectReason = await showReasonDialog(
        title: 'Reject Car',
        hintText: 'Enter reason for rejecting car',
      );
      if (rejectReason == null) {
        return;
      }
      try {
        await carProvider.updateCarStatus(
          carId: car.id ?? '',
          previousStatus: car.status as CarStatus,
          newStatus: CarStatus.rejected,
          modifiedById: currentUserId,
          statusDescription: rejectReason,
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Car rejected Successfully.',
        );
      } catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error rejecting car. Please try again later.',
        );
      }
    }

    Future<void> haltCar() async {
      Navigator.of(context).pop();
      String? haltReason = '';
      if (isAdmin) {
        haltReason = await showReasonDialog(
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
      }
      try {
        await carProvider.updateCarStatus(
          carId: car.id ?? '',
          previousStatus: car.status as CarStatus,
          newStatus: isAdmin ? CarStatus.haltedByAdmin : CarStatus.haltedByHost,
          modifiedById: currentUserId,
          statusDescription: haltReason,
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Car deleted successfully.',
        );
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error halting car. Please try again later.',
        );
      }
    }

    Future<void> requestUnhaltCar() async {
      Navigator.of(context).pop();
      try {
        await carProvider.updateCarStatus(
          carId: car.id ?? '',
          previousStatus: car.status as CarStatus,
          newStatus: CarStatus.unhaltRequested,
          modifiedById: currentUserId,
          statusDescription: '',
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Car unhalt requested successfully.',
        );
      } catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error requesting car unhalt. Please try again later.',
        );
      }
    }

    Future<void> unhaltCar() async {
      Navigator.of(context).pop();
      try {
        await carProvider.updateCarStatus(
          carId: car.id ?? '',
          previousStatus: car.status as CarStatus,
          newStatus: CarStatus.pendingApproval,
          modifiedById: currentUserId,
          statusDescription: '',
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Car un-halted successfully.',
        );
      } catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error un-halting car. Please try again later.',
        );
      }
    }

    List<Widget> buttons = [];

    Widget approveCarButton() {
      return TextButton.icon(
        onPressed: approveCar,
        icon: const Icon(Icons.check_circle_rounded),
        label: const Text(
          'Approve Car',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

// Reject Car button
    Widget rejectCarButton() {
      return TextButton.icon(
        onPressed: rejectCar,
        icon: const Icon(Icons.cancel_rounded),
        label: const Text(
          'Reject Car',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

// Halt Car button
    Widget haltCarButton() {
      return TextButton.icon(
        onPressed: haltCar,
        icon: const Icon(Icons.pause_rounded),
        label: const Text(
          'Halt Car',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

// Delete Car button
    Widget deleteCarButton() {
      return TextButton.icon(
        onPressed: deleteCar,
        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
        label: const Text(
          'Delete Car',
          style: TextStyle(fontSize: 18.0, color: Colors.red),
        ),
      );
    }

// Request Unhalt Car button
    Widget requestUnhaltCarButton() {
      return TextButton.icon(
        onPressed: requestUnhaltCar,
        icon: const Icon(Icons.play_circle_filled_rounded),
        label: const Text(
          'Request Unhalt Car',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

// Unhalt Car button
    Widget unhaltCarButton() {
      return TextButton.icon(
        onPressed: unhaltCar,
        icon: const Icon(Icons.play_circle_filled_rounded),
        label: const Text(
          'Unhalt Car',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    // update car button
    Widget updateCarButton() {
      return TextButton.icon(
        onPressed: updateCar,
        icon: const Icon(Icons.edit),
        label: const Text(
          'Update Car',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    void loadButtonsByCarStatusAndRole() {
      switch (car.status) {
        case CarStatus.currentlyRented:
          if (isAdmin) {
            // no buttons for currentlyRented
          } else {
            // no buttons for currentlyRented
          }
          break;

        case CarStatus.upcomingRental:
          if (isAdmin) {
            // no buttons for upcomingRental
          } else {
            // no buttons for upcomingRental
          }
          break;

        case CarStatus.uploaded:
          if (isAdmin) {
            // Approve, Reject, Halt, Delete
            buttons.addAll(
              [
                approveCarButton(),
                rejectCarButton(),
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          } else {
            // update, halt, delete
            buttons.addAll(
              [
                updateCarButton(),
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          }
          break;

        case CarStatus.pendingApproval:
          if (isAdmin) {
            // Approve, Reject, Halt, Delete
            buttons.addAll(
              [
                approveCarButton(),
                rejectCarButton(),
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          } else {
            // update, halt, delete
            buttons.addAll(
              [
                updateCarButton(),
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          }
          break;

        case CarStatus.updated:
          if (isAdmin) {
            // Approve, Reject, Halt, Delete
            buttons.addAll(
              [
                approveCarButton(),
                rejectCarButton(),
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          } else {
            // update, halt, delete
            buttons.addAll(
              [
                updateCarButton(),
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          }
          break;

        case CarStatus.approved:
          if (isAdmin) {
            // halt, delete
            buttons.addAll(
              [
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          } else {
            // update, halt, delete
            buttons.addAll(
              [
                updateCarButton(),
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          }
          break;

        case CarStatus.rejected:
          if (isAdmin) {
            // approve, halt, delete
            buttons.addAll(
              [
                approveCarButton(),
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          } else {
            // update, halt, delete
            buttons.addAll(
              [
                updateCarButton(),
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          }
          break;

        case CarStatus.haltedByHost:
          if (isAdmin) {
            // halt, delete
            buttons.addAll(
              [
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          } else {
            // unhalt, delete
            buttons.addAll(
              [
                unhaltCarButton(),
                deleteCarButton(),
              ],
            );
          }
          break;

        case CarStatus.haltedByAdmin:
          if (isAdmin) {
            // unhalt, delete
            buttons.addAll(
              [
                unhaltCarButton(),
                deleteCarButton(),
              ],
            );
          } else {
            // update, request unhalt, delete
            buttons.addAll(
              [
                updateCarButton(),
                requestUnhaltCarButton(),
                deleteCarButton(),
              ],
            );
          }
          break;

        case CarStatus.unhaltRequested:
          if (isAdmin) {
            // unhalt, delete
            buttons.addAll(
              [
                unhaltCarButton(),
                deleteCarButton(),
              ],
            );
          } else {
            // update, delete
            buttons.addAll(
              [
                updateCarButton(),
                deleteCarButton(),
              ],
            );
          }
          break;

        case CarStatus.deletedByHost:
          if (isAdmin) {
            // delete
            buttons.add(
              deleteCarButton(),
            );
          } else {
            // no buttons for deletedByHost for non admin
          }
          break;

        case CarStatus.deletedByAdmin:
          if (isAdmin) {
            // no buttons for deletedByAdmin for admin
          } else {
            // no buttons for deletedByAdmin for non admin
          }
          break;

        default:
          break;
      }
    }

    loadButtonsByCarStatusAndRole();

    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Edit Car',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5.0),
          const Divider(),
          const SizedBox(height: 15.0),
          ...buttons,
        ],
      ),
    );
  }
}
