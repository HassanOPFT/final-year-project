import 'package:flutter/material.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/car.dart';
import '../../providers/car_provider.dart';
import '../../utils/assets_paths.dart';
import '../../widgets/car_status_indicator.dart';
import '../../widgets/card/car_feature_card.dart';

class HostCarDetailsScreen extends StatelessWidget {
  final String carId;

  const HostCarDetailsScreen({
    super.key,
    required this.carId,
  });

  @override
  Widget build(BuildContext context) {
    Padding buildSectionTitle({required String sectionTitle}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Text(
          sectionTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Details'),
      ),
      body: FutureBuilder<Car?>(
        future:
            Provider.of<CarProvider>(context, listen: false).getCarById(carId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomProgressIndicator();
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading car details.'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No car details available.'));
          } else {
            final car = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 250,
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
                        Positioned(
                          top: 10.0,
                          right: 10.0,
                          child: Consumer<CarProvider>(
                            builder: (
                              context,
                              value,
                              _,
                            ) {
                              return CarStatusIndicator(
                                carStatus: car.status as CarStatus,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
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
                                  style: const TextStyle(),
                                ),
                                const SizedBox(width: 4.0),
                                const Text(
                                  'hr',
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
                                  'day',
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
                    buildSectionTitle(sectionTitle: 'Car Features'),
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
                    const SizedBox(height: 10.0),
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
                    buildSectionTitle(sectionTitle: 'Car Details'),
                    buildSectionTitle(sectionTitle: 'Car Details'),
                    buildSectionTitle(sectionTitle: 'Car Details'),
                    buildSectionTitle(sectionTitle: 'Car Details'),
                    buildSectionTitle(sectionTitle: 'Car Details'),
                    Text(
                      car.carType?.name ?? 'No car type provided',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        Icon(Icons.star, color: Colors.amber),
                        Icon(Icons.star, color: Colors.amber),
                        Icon(Icons.star, color: Colors.amber),
                        Icon(Icons.star_border, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          '4.0 (120 reviewers)',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      car.description ?? 'No description provided',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Facilities',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            // Handle "See All" button press
                          },
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '\$${car.dayPrice.toString()}/day',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Car Images',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: car.imagesUrl?.length ?? 0,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(car.imagesUrl?[index] ?? ''),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Host ID'),
                      subtitle: Text(car.hostId ?? 'No host ID provided'),
                    ),
                    ListTile(
                      title: const Text('Host Bank Account ID'),
                      subtitle: Text(car.hostBankAccountId ??
                          'No host bank account ID provided'),
                    ),
                    ListTile(
                      title: const Text('Manufacturer'),
                      subtitle:
                          Text(car.manufacturer ?? 'No manufacturer provided'),
                    ),
                    ListTile(
                      title: const Text('Manufacture Year'),
                      subtitle: Text(car.manufactureYear.toString()),
                    ),
                    ListTile(
                      title: const Text('Color'),
                      subtitle: Text(car.color ?? 'No color provided'),
                    ),
                    ListTile(
                      title: const Text('Engine Type'),
                      subtitle: Text(
                          car.engineType?.name ?? 'No engine type provided'),
                    ),
                    ListTile(
                      title: const Text('Hourly Price'),
                      subtitle: Text(car.hourPrice.toString()),
                    ),
                    ListTile(
                      title: const Text('Status'),
                      subtitle: Text(car.status?.name ?? 'No status provided'),
                    ),
                    ListTile(
                      title: const Text('Reference Number'),
                      subtitle: Text(car.referenceNumber ??
                          'No reference number provided'),
                    ),
                    ListTile(
                      title: const Text('Created At'),
                      subtitle: Text(car.createdAt.toString()),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
