// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/providers/address_provider.dart';
import 'package:prime/utils/snackbar.dart';
import 'package:prime/widgets/admin_car_address.dart';
import 'package:prime/widgets/bottom_sheet/edit_car_bottom_sheet.dart';
import 'package:prime/widgets/card/host_car_bank_account_card.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';
import 'package:prime/widgets/host_car_verification_document.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/car.dart';
import '../../models/status_history.dart';
import '../../models/user.dart';
import '../../models/verification_document.dart';
import '../../providers/bank_account_provider.dart';
import '../../providers/car_provider.dart';
import '../../providers/status_history_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/verification_document_provider.dart';
import '../../services/firebase/firebase_auth_service.dart';
import '../../utils/assets_paths.dart';
import '../../utils/navigate_with_animation.dart';
import '../../widgets/card/car_feature_card.dart';
import '../../widgets/copy_text.dart';
import '../../widgets/host_car_address.dart';
import '../../widgets/images/car_images_carousel.dart';
import '../../widgets/latest_status_history_record.dart';
import '../../widgets/tiles/manage_verification_document_tile.dart';
import 'update_host_car_screen.dart';

// TODO: status indicator is not updating in real time, check the provider

class ManageCarScreen extends StatelessWidget {
  final String carId;
  final bool isAdmin;

  const ManageCarScreen({
    super.key,
    required this.carId,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(context);
    final currentUserId = FirebaseAuthService().currentUser?.uid ?? '';
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    Padding buildSectionTitle({required String sectionTitle}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Text(
          sectionTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      );
    }

    Future<StatusHistory?> getMostRecentStatusHistory(String? carId) async {
      if (carId == null || carId.isEmpty) {
        return null;
      }
      try {
        final statusHistoryProvider = Provider.of<StatusHistoryProvider>(
          context,
        );
        final mostRecentStatusHistory =
            await statusHistoryProvider.getMostRecentStatusHistory(
          carId,
        );
        return mostRecentStatusHistory;
      } catch (_) {
        return null;
      }
    }

    void updateCar(Car car) {
      animatedPushNavigation(
        context: context,
        screen: UpdateHostCarScreen(car: car),
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

    Future<void> deleteCar(Car car) async {
      // TODO: the role needs to be updated if the host doesn't have other cars
      bool confirmDeletion = await confirmDeleteCar();
      if (!confirmDeletion) {
        return;
      }

      try {
        if (currentUserId.isEmpty || car.id == null || car.id!.isEmpty) {
          throw Exception(
            'Error deleting car. Please provide valid current user id and car id.',
          );
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

          // delete car registration document if exists
          if (car.registrationDocumentId != null &&
              car.registrationDocumentId!.isNotEmpty) {
            final registrationDocument =
                await verificationDocumentProvider.getVerificationDocumentById(
              car.registrationDocumentId ?? '',
            );
            await verificationDocumentProvider.deleteVerificationDocument(
              documentId: car.registrationDocumentId ?? '',
              referenceNumber: registrationDocument?.referenceNumber ?? '',
              documentType: registrationDocument?.documentType
                  as VerificationDocumentType,
              userRole: currentUserRole,
              previousStatus:
                  registrationDocument?.status as VerificationDocumentStatus,
              modifiedById: currentUserId,
            );
          }
          // delete car road tax document if exists
          if (car.roadTaxDocumentId != null &&
              car.roadTaxDocumentId!.isNotEmpty) {
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
          }
          // delete car insurance document if exists
          if (car.insuranceDocumentId != null &&
              car.insuranceDocumentId!.isNotEmpty) {
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
        }
        Navigator.of(context).pop();
        buildSuccessSnackbar(
          context: context,
          message: 'Car deleted successfully.',
        );
      } catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error deleting car. Please try again later.',
        );
      }
    }

    Future<void> approveCar(Car car) async {
      // TODO: Check for car documents if approved and if address is provided
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

    Future<void> rejectCar(Car car) async {
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

    Future<void> haltCar(Car car) async {
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
          message: 'Car halted successfully.',
        );
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error halting car. Please try again later.',
        );
      }
    }

    Future<void> requestUnhaltCar(Car car) async {
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

    Future<void> unhaltCar(Car car) async {
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

    Future<void> showEditCarBottomSheet(Car car) async {
      final userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );
      final userRole = userProvider.user?.userRole ?? UserRole.customer;
      final isAdmin = userRole == UserRole.primaryAdmin ||
          userRole == UserRole.secondaryAdmin;
      if (car.status == CarStatus.deletedByHost && !isAdmin) {
        buildAlertSnackbar(
          context: context,
          message: 'Modification is not allowed for deleted car.',
        );
        return;
      } else if (car.status == CarStatus.deletedByAdmin) {
        buildAlertSnackbar(
          context: context,
          message: 'Modification is not allowed for car deleted car.',
        );
        return;
      } else if (car.status == CarStatus.currentlyRented) {
        buildAlertSnackbar(
          context: context,
          message: 'Modification is not allowed for currently rented car.',
        );
        return;
      } else if (car.status == CarStatus.upcomingRental) {
        buildAlertSnackbar(
          context: context,
          message: 'Modification is not allowed for upcoming rental car.',
        );
        return;
      }

      await showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (BuildContext context) {
          return EditCarBottomSheet(
            car: car,
            updateCar: updateCar,
            deleteCar: deleteCar,
            approveCar: approveCar,
            rejectCar: rejectCar,
            haltCar: haltCar,
            requestUnhaltCar: requestUnhaltCar,
            unhaltCar: unhaltCar,
            isAdmin: isAdmin,
          );
        },
      );
    }

    Provider.of<AddressProvider>(context);
    final bankAccountProvider = Provider.of<BankAccountProvider>(context);
    final verificationDocumentProvider =
        Provider.of<VerificationDocumentProvider>(context);

    return FutureBuilder<Car?>(
      future: carProvider.getCarById(carId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Car Details'),
            ),
            body: const CustomProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Car Details'),
            ),
            body: const Center(
              child: Text('Error loading car details.'),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Car Details'),
            ),
            body: const Center(
              child: Text('Car details not available.'),
            ),
          );
        } else {
          final car = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Car Details'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => showEditCarBottomSheet(car),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CarImagesCarousel(
                      imagesUrl: car.imagesUrl ?? [],
                      carStatus: car.status as CarStatus,
                      showCarStatus: true,
                    ),
                    const SizedBox(height: 5.0),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                '${car.manufacturer} ${car.model} ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.0,
                                ),
                              ),
                              Text(
                                '${car.manufactureYear} ',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'RM${car.hourPrice?.toStringAsFixed(1) ?? 'N/A'}',
                                ),
                                const SizedBox(width: 4.0),
                                const Text(
                                  '/hr',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'RM${car.dayPrice?.toStringAsFixed(1) ?? 'N/A'}',
                                ),
                                const SizedBox(width: 4.0),
                                const Text(
                                  '/day',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      car.description ?? 'No description provided',
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    buildSectionTitle(sectionTitle: 'Host'),
                    FutureBuilder<User?>(
                      future: Provider.of<UserProvider>(context, listen: false)
                          .getUserDetails(car.hostId ?? ''),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error loading user details.'));
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          return const Center(
                              child: Text('User details not available.'));
                        } else {
                          final user = snapshot.data!;
                          return ListTile(
                            leading: ClipOval(
                              child: user.userProfileUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: user.userProfileUrl ?? '',
                                      width: 50.0,
                                      height: 50.0,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    )
                                  : const Icon(Icons.person),
                            ),
                            title: Text(
                              '${user.userFirstName ?? ''} ${user.userLastName ?? ''}',
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              user.userPhoneNumber ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    buildSectionTitle(sectionTitle: 'Features'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CarFeatureCard(
                          featureIcon: Icons.color_lens,
                          featureName: 'Color',
                          featureValue: car.color ?? 'N/A',
                        ),
                        CarFeatureCard(
                          featureIcon: Image.asset(
                            AssetsPaths.transmissionTypeIcon,
                            width: 23.0,
                            height: 19.0,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          featureName: 'Transmission',
                          featureValue:
                              car.transmissionType?.transmissionTypeString ??
                                  'N/A',
                        ),
                        CarFeatureCard(
                          featureIcon: Image.asset(
                            AssetsPaths.carSeatIcon,
                            width: 25.0,
                            height: 25.0,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          featureName: 'Seats',
                          featureValue: car.seats?.toString() ?? 'N/A',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CarFeatureCard(
                          featureIcon: Icons.directions_car,
                          featureName: 'Car Type',
                          featureValue:
                              car.carType?.getCarTypeString() ?? 'N/A',
                        ),
                        CarFeatureCard(
                          featureIcon: Image.asset(
                            AssetsPaths.engineTypeIcon,
                            width: 28.0,
                            height: 26.0,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          featureName: 'Engine Type',
                          featureValue:
                              car.engineType?.engineTypeString ?? 'N/A',
                        ),
                      ],
                    ),
                    buildSectionTitle(sectionTitle: 'Address'),
                    if (!isAdmin)
                      HostCarAddress(
                        carDefaultAddressId: car.defaultAddressId ?? '',
                        carId: car.id ?? '',
                      ),
                    if (isAdmin)
                      AdminCarAddress(
                        addressId: car.defaultAddressId,
                      ),
                    buildSectionTitle(sectionTitle: 'Associated Bank Account'),
                    HostCarBankAccountCard(
                      bankAccountProvider: bankAccountProvider,
                      hostBankAccountId: car.hostBankAccountId ?? '',
                    ),
                    buildSectionTitle(sectionTitle: 'Car Registration'),
                    if (!isAdmin)
                      HostCarVerificationDocument(
                        verificationDocumentType:
                            VerificationDocumentType.carRegistration,
                        verificationDocumentId:
                            car.registrationDocumentId ?? '',
                        verificationDocumentProvider:
                            verificationDocumentProvider,
                        linkedObjectId: car.id ?? '',
                        uploadButtonText: 'Upload Registration',
                      ),
                    if (isAdmin)
                      AdminVerificationDocumentTile(
                        verificationDocumentId:
                            car.registrationDocumentId ?? '',
                      ),
                    buildSectionTitle(sectionTitle: 'Car Insurance'),
                    if (!isAdmin)
                      HostCarVerificationDocument(
                        verificationDocumentType:
                            VerificationDocumentType.carInsurance,
                        verificationDocumentId: car.insuranceDocumentId ?? '',
                        verificationDocumentProvider:
                            verificationDocumentProvider,
                        linkedObjectId: car.id ?? '',
                        uploadButtonText: 'Upload Insurance',
                      ),
                    if (isAdmin)
                      AdminVerificationDocumentTile(
                        verificationDocumentId: car.insuranceDocumentId ?? '',
                      ),
                    buildSectionTitle(sectionTitle: 'Car Road Tax'),
                    if (!isAdmin)
                      HostCarVerificationDocument(
                        verificationDocumentType:
                            VerificationDocumentType.carRoadTax,
                        verificationDocumentId: car.roadTaxDocumentId ?? '',
                        verificationDocumentProvider:
                            verificationDocumentProvider,
                        linkedObjectId: car.id ?? '',
                        uploadButtonText: 'Upload Road Tax',
                      ),
                    if (isAdmin)
                      AdminVerificationDocumentTile(
                        verificationDocumentId: car.roadTaxDocumentId ?? '',
                      ),
                    const SizedBox(height: 30.0),
                    LatestStatusHistoryRecord(
                      fetchStatusHistory: getMostRecentStatusHistory,
                      linkedObjectId: car.id ?? carId,
                    ),
                    const SizedBox(height: 15.0),
                    const Divider(thickness: 0.3),
                    const SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ref Number'),
                        CopyText(
                          text: car.referenceNumber ?? 'N/A',
                        ),
                      ],
                    ),
                    const SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Added on'),
                        Text(
                          DateFormat.yMMMd()
                              .add_jm()
                              .format(car.createdAt as DateTime),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15.0),
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
