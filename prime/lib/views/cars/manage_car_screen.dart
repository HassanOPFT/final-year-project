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
import '../../utils/assets_paths.dart';
import '../../widgets/card/car_feature_card.dart';
import '../../widgets/copy_text.dart';
import '../../widgets/host_car_address.dart';
import '../../widgets/images/car_images_carousel.dart';
import '../../widgets/latest_status_history_record.dart';
import '../../widgets/tiles/manage_verification_document_tile.dart';

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
            isAdmin: isAdmin,
            car: car,
          );
        },
      );
    }

    Provider.of<AddressProvider>(context);
    final bankAccountProvider = Provider.of<BankAccountProvider>(context);
    final verificationDocumentProvider =
        Provider.of<VerificationDocumentProvider>(context);

    return FutureBuilder<Car?>(
      future: Provider.of<CarProvider>(context).getCarById(carId),
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
                                  fontSize: 28.0,
                                ),
                              ),
                              Text(
                                '${car.manufactureYear} ',
                                style: const TextStyle(
                                  fontSize: 18.0,
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
                    // car description text
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
                            height: 20.0,
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
                          featureValue: car.engineType?.name ?? 'N/A',
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
