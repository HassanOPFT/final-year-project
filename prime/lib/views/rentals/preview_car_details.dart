// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/widgets/images/car_address_image_preview.dart';
import 'package:provider/provider.dart';

import '../../models/car.dart';
import '../../models/user.dart';
import '../../providers/car_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/car_features_row.dart';
import '../../widgets/card/car_rental_reviews.dart';
import '../../widgets/custom_progress_indicator.dart';
import '../../widgets/images/car_images_carousel.dart';

class PreviewCarDetails extends StatefulWidget {
  final String carId;
  const PreviewCarDetails({
    super.key,
    required this.carId,
  });

  @override
  State<PreviewCarDetails> createState() => _RentCarScreenState();
}

class _RentCarScreenState extends State<PreviewCarDetails> {
  @override
  void initState() {
    super.initState();
  }

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

    return RefreshIndicator(
      edgeOffset: 110.0,
      onRefresh: () async {
        setState(() {});
      },
      child: FutureBuilder<Car?>(
        future: carProvider.getCarById(widget.carId),
        builder: (contest, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Car Preview'),
              ),
              body: const CustomProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Car Preview'),
              ),
              body: const Center(
                child: Text('Error loading car details.'),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Car Preview'),
              ),
              body: const Center(
                child: Text('Car details not available.'),
              ),
            );
          } else {
            final car = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                title: const Text('Car Preview'),
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
                      buildSectionTitle(sectionTitle: 'Host'),
                      FutureBuilder<User?>(
                        future:
                            Provider.of<UserProvider>(context, listen: false)
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
                            // TODO: add verified text and icon 'Verified By PRIME'
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
                                'Joined on ${DateFormat.yMMM().format(car.createdAt ?? DateTime.now())}',
                              ),
                            );
                          }
                        },
                      ),
                      buildSectionTitle(sectionTitle: 'Description'),
                      Text(
                        car.description ?? 'No description provided',
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      buildSectionTitle(sectionTitle: 'Features'),
                      CarFeaturesRow(car: car),
                      buildSectionTitle(sectionTitle: 'Address'),
                      CarAddressImagePreview(addressId: car.defaultAddressId),
                      const CarRentalReviews(carId: 'car.id'),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
