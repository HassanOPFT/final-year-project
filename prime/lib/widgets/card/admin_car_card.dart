import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/views/cars/manage_car_screen.dart';
import 'package:prime/widgets/car_status_indicator.dart';

import '../../models/car.dart';
import '../custom_progress_indicator.dart';

class AdminCarCard extends StatelessWidget {
  final Car car;
  const AdminCarCard({
    super.key,
    required this.car,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => animatedPushNavigation(
        context: context,
        screen: ManageCarScreen(
          carId: car.id ?? '',
          isAdmin: true,
        ),
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
                              fontSize: 26.0,
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
                    child: CarStatusIndicator(
                      carStatus: car.status as CarStatus,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
