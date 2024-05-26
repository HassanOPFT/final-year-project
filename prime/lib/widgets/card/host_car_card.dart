import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/providers/car_provider.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/views/cars/host_car_details_screen.dart';
import 'package:prime/widgets/car_status_indicator.dart';
import 'package:provider/provider.dart';

import '../../models/car.dart';
import '../custom_progress_indicator.dart';

class HostCarCard extends StatelessWidget {
  final Car car;
  const HostCarCard({
    super.key,
    required this.car,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => animatedPushNavigation(
        context: context,
        screen: HostCarDetailsScreen(
          carId: car.id ?? '',
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
              // add date created text here
              const SizedBox(height: 10.0),
              Text(
                'Added on ${DateFormat.yMMMd().add_jm().format(car.createdAt as DateTime)}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
