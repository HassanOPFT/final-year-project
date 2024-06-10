import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/views/home/customer_explore_screen.dart';
import 'package:prime/views/rentals/customer_rentals_screen.dart';
import 'package:prime/widgets/app_logo.dart';
import 'package:prime/widgets/copy_text.dart';
import 'package:provider/provider.dart';

import '../../models/car_rental.dart';
import '../../providers/car_rental_provider.dart';
import '../../widgets/custom_progress_indicator.dart';

class CarRentalConfirmationScreen extends StatelessWidget {
  final String carName;
  final String carImage;
  final String carColor;
  final String carAddress;
  final DateTime pickUpTime;
  final DateTime dropOffTime;
  final String totalPrice;
  final String carRentalId;

  const CarRentalConfirmationScreen({
    super.key,
    required this.carName,
    required this.carImage,
    required this.carColor,
    required this.carAddress,
    required this.pickUpTime,
    required this.dropOffTime,
    required this.totalPrice,
    required this.carRentalId,
  });

  @override
  Widget build(BuildContext context) {
    final carRentalProvider =
        Provider.of<CarRentalProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const AppLogo(height: 120.0),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<CarRental?>(
        future: carRentalProvider.getCarRentalById(carRentalId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomProgressIndicator();
          } else if (snapshot.hasError) {
            return Column(
              children: [
                const Center(
                  child: Text(
                    'An error occurred while getting Car Rental!',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                FilledButton(
                  onPressed: () => animatedPushReplacementNavigation(
                    context: context,
                    screen: const CustomerRentalsScreen(),
                  ),
                  child: const Text('Explore Screen'),
                ),
              ],
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Column(
              children: [
                const Center(
                  child: Text(
                    'An error occurred while getting Car Rental!',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                FilledButton(
                  onPressed: () => animatedPushReplacementNavigation(
                    context: context,
                    screen: const CustomerRentalsScreen(),
                  ),
                  child: const Text('Explore Screen'),
                ),
              ],
            );
          }
          final carRental = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 10.0),
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 120,
                        color: Colors.green,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          'Your Car Rental has been Confirmed!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: CachedNetworkImage(
                                imageUrl: carImage,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const CustomProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Center(child: Icon(Icons.error)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  carName,
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  carColor,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(thickness: 0.3),
                      Row(
                        children: [
                          const Text(
                            'Reference Number',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          const Spacer(),
                          CopyText(
                            text: carRental.referenceNumber ?? 'N/A',
                            fontSize: 16.0,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        children: [
                          const Text(
                            'Created At',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat.yMMMd()
                                .add_jm()
                                .format(carRental.createdAt ?? DateTime.now()),
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      const Divider(thickness: 0.3),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          'Pick-Up & Drop-Off',
                          style: TextStyle(
                            fontSize: 22.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    carAddress,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20.0),
                            _buildIconTextRowWithDate(
                              context,
                              Icons.access_time,
                              'Pick-Up Time',
                              pickUpTime,
                            ),
                            const SizedBox(height: 20.0),
                            _buildIconTextRowWithDate(
                              context,
                              Icons.access_time,
                              'Drop-Off Time',
                              dropOffTime,
                            ),
                          ],
                        ),
                      ),
                      const Divider(thickness: 0.3),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              totalPrice,
                              style: const TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      SizedBox(
                        height: 50.0,
                        child: FilledButton(
                          onPressed: () => animatedPushReplacementNavigation(
                            context: context,
                            screen: const CustomerRentalsScreen(),
                          ),
                          child: const Text(
                            'View Rentals',
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50.0,
                        child: TextButton(
                          onPressed: () => animatedPushReplacementNavigation(
                            context: context,
                            screen: const CustomerExploreScreen(),
                          ),
                          child: const Text(
                            'Explore Screen',
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconTextRowWithDate(
    BuildContext context,
    IconData icon,
    String label,
    DateTime dateTime,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8.0),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
        const Spacer(),
        Text(
          DateFormat.yMMMd().add_jm().format(dateTime),
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }
}
