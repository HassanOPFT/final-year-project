import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/utils/snackbar.dart';
import 'package:prime/widgets/images/car_address_image_preview.dart';
import 'package:provider/provider.dart';

import '../../models/car.dart';
import '../../models/user.dart';
import '../../providers/car_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/assets_paths.dart';
import '../../widgets/car_rental_schedule_picker.dart';
import '../../widgets/card/car_feature_card.dart';
import '../../widgets/card/car_rental_reviews.dart';
import '../../widgets/custom_progress_indicator.dart';
import '../../widgets/images/car_images_carousel.dart';

class RentCarScreen extends StatelessWidget {
  final String carId;
  const RentCarScreen({
    super.key,
    required this.carId,
  });

  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(
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

    return StreamBuilder<CarStatus?>(
        stream: carProvider.listenToCarStatus(carId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Rent Car'),
              ),
              body: const CustomProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Rent Car'),
              ),
              body: const Center(
                child: Text('Error occurred. Please try again later.'),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Rent Car'),
              ),
              body: const Center(
                child: Text('Car details is not available at the moment.'),
              ),
            );
          }
          if (snapshot.data != CarStatus.approved) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.of(context).pop();
              buildAlertSnackbar(
                context: context,
                message: 'This car is not available anymore.',
              );
            });
          }
          return FutureBuilder<Car?>(
            future: carProvider.getCarById(carId),
            builder: (contest, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Rent Car'),
                  ),
                  body: const CustomProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Rent Car'),
                  ),
                  body: const Center(
                    child: Text('Error loading car details.'),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data == null) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Rent Car'),
                  ),
                  body: const Center(
                    child: Text('Car details not available.'),
                  ),
                );
              } else {
                final car = snapshot.data!;
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Rent Car'),
                  ),
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        10.0,
                        5.0,
                        10.0,
                        20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CarImagesCarousel(
                            imagesUrl: car.imagesUrl ?? [],
                            carStatus: car.status as CarStatus,
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
                            future: Provider.of<UserProvider>(context,
                                    listen: false)
                                .getUserDetails(car.hostId ?? ''),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return const Center(
                                    child: Text('Error loading user details.'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data == null) {
                                return const Center(
                                    child: Text('User details not available.'));
                              } else {
                                final user = snapshot.data!;
                                // TODO: add verified text and icon
                                return ListTile(
                                  leading: ClipOval(
                                    child: user.userProfileUrl != null
                                        ? CachedNetworkImage(
                                            imageUrl: user.userProfileUrl ?? '',
                                            width: 50.0,
                                            height: 50.0,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const CustomProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
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
                                    'Joined on ${DateFormat.yMMM().format(car.createdAt as DateTime)}',
                                  ),
                                );
                              }
                            },
                          ),
                          // TODO: Change design to a design timilar to play store app feature two
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                                featureName: 'Transmission',
                                featureValue: car.transmissionType
                                        ?.transmissionTypeString ??
                                    'N/A',
                              ),
                              CarFeatureCard(
                                featureIcon: Image.asset(
                                  AssetsPaths.carSeatIcon,
                                  width: 25.0,
                                  height: 25.0,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                                featureName: 'Engine Type',
                                featureValue:
                                    car.engineType?.engineTypeString ?? 'N/A',
                              ),
                            ],
                          ),
                          buildSectionTitle(sectionTitle: 'Address'),
                          CarAddressImagePreview(
                              addressId: car.defaultAddressId),
                          // TODO: Implelment the Reviews section + most recent review
                          buildSectionTitle(sectionTitle: 'Reviews'),
                          const CarRentalReviews(),
                          CarRentalSchedulePicker(carId: car.id ?? ''),
                          // TODO: Implement that the current user has to have approved identity in order to proceed, create a container
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          );
        });
  }
}
