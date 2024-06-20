import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/models/car_rental.dart';
import 'package:prime/models/car.dart';
import 'package:prime/models/user.dart';
import 'package:prime/providers/car_rental_provider.dart';
import 'package:prime/providers/status_history_provider.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/views/rentals/car_rental_details_screen.dart';
import 'package:prime/widgets/car_rental_status_indicator.dart';
import 'package:provider/provider.dart';
import '../custom_progress_indicator.dart';

class CarRentalCard extends StatelessWidget {
  final CarRental carRental;
  final Car car;
  final UserRole userRole;

  const CarRentalCard({
    super.key,
    required this.carRental,
    required this.car,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final duration = carRental.endDate!.difference(carRental.startDate!);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    var totalForDays = days * (car.dayPrice ?? 0.0);
    totalForDays = double.parse(totalForDays.toStringAsFixed(1));
    var totalForHours = hours * (car.hourPrice ?? 0.0);
    totalForHours = double.parse(totalForHours.toStringAsFixed(1));
    final totalPrice = totalForDays + totalForHours;
    final durationText =
        '${days > 0 ? '$days days' : ''}${days > 0 && hours > 0 ? ' and ' : ''}${hours > 0 ? '$hours hours' : ''}';

    return GestureDetector(
      onTap: () => animatedPushNavigation(
        context: context,
        screen: CarRentalDetailsScreen(carRentalId: carRental.id ?? ''),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: 5.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${car.manufacturer} ${car.model}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                  Text(
                    DateFormat.yMMMd()
                        .add_jm()
                        .format(carRental.createdAt as DateTime),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 200.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: CachedNetworkImage(
                        imageUrl: car.imagesUrl?.first ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const CustomProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Center(child: Icon(Icons.error)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10.0,
                    right: 10.0,
                    child: Consumer2<CarRentalProvider, StatusHistoryProvider>(
                      builder:
                          (context, carProvider, statusHistoryProvider, _) {
                        return CarRentalStatusIndicator(
                          carRentalStatus: carRental.status ??
                              CarRentalStatus.rentedByCustomer,
                          userRole: userRole,
                        );
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          durationText,
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          'RM${totalPrice.toString()}',
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
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
