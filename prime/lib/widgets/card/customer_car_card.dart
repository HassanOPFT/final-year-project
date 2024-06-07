import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:prime/views/rentals/rent_car_screen.dart';

import '../../models/car.dart';
import '../../utils/assets_paths.dart';
import '../../utils/navigate_with_animation.dart';
import '../custom_progress_indicator.dart';

class CustomerCarCard extends StatelessWidget {
  final Car car;
  const CustomerCarCard({
    super.key,
    required this.car,
  });

  @override
  Widget build(BuildContext context) {
    Row carFeature({
      required dynamic icon,
      required String featureName,
    }) {
      Widget buildFeatureIcon() {
        if (icon is IconData) {
          return Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          );
        } else if (icon is Image) {
          return icon;
        } else {
          return const SizedBox.shrink();
        }
      }

      return Row(
        children: [
          buildFeatureIcon(),
          const SizedBox(width: 4.0),
          Text(
            featureName,
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () => animatedPushNavigation(
        context: context,
        screen: RentCarScreen(carId: car.id ?? ''),
      ),
      child: Card(
        elevation: 5.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
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
                              style: const TextStyle(),
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
                              style: const TextStyle(),
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
              ),
              SizedBox(
                width: double.infinity,
                height: 200,
                child: car.imagesUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: CachedNetworkImage(
                          imageUrl: car.imagesUrl?.first ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const CustomProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Center(child: Icon(Icons.error)),
                        ),
                      )
                    : const Center(
                        child: Text('Error loading image'),
                      ),
              ),
              //? Add Car Address
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    carFeature(
                      icon: Icons.directions_car,
                      featureName: car.carType?.getCarTypeString() ?? 'N/A',
                    ),
                    carFeature(
                      icon: Image.asset(
                        AssetsPaths.transmissionTypeIcon,
                        width: 23.0,
                        height: 19.0,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      featureName:
                          car.transmissionType?.transmissionTypeString ?? 'N/A',
                    ),
                    carFeature(
                      icon: Image.asset(
                        AssetsPaths.engineTypeIcon,
                        width: 28.0,
                        height: 26.0,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      featureName: car.engineType?.engineTypeString ?? 'N/A',
                    ),
                    carFeature(
                      icon: Image.asset(
                        AssetsPaths.carSeatIcon,
                        width: 30.0,
                        height: 25.0,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      featureName: car.seats?.toString() ?? 'N/A',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
