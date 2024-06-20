import 'package:flutter/material.dart';

import '../models/car.dart';
import '../utils/assets_paths.dart';
import 'card/car_feature_card.dart';

class CarFeaturesRow extends StatelessWidget {
  const CarFeaturesRow({
    super.key,
    required this.car,
  });

  final Car car;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CarFeatureCard(
            featureIcon: Icons.directions_car,
            featureName: 'Car Type',
            featureValue: car.carType?.getCarTypeString() ?? 'N/A',
          ),
          verticalDivider(),
          CarFeatureCard(
            featureIcon: Image.asset(
              AssetsPaths.engineTypeIcon,
              width: 28.0,
              height: 26.0,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            featureName: 'Engine Type',
            featureValue: car.engineType?.engineTypeString ?? 'N/A',
          ),
          verticalDivider(),
          CarFeatureCard(
            featureIcon: Image.asset(
              AssetsPaths.transmissionTypeIcon,
              width: 23.0,
              height: 19.0,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            featureName: 'Transmission',
            featureValue: car.transmissionType?.transmissionTypeString ?? 'N/A',
          ),
          verticalDivider(),
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
          verticalDivider(),
          CarFeatureCard(
            featureIcon: Icons.color_lens,
            featureName: 'Color',
            featureValue: car.color ?? 'N/A',
          ),
        ],
      ),
    );
  }

  SizedBox verticalDivider() {
    return const SizedBox(
      height: 40.0,
      width: 10.0,
      child: VerticalDivider(thickness: 0.3),
    );
  }
}
