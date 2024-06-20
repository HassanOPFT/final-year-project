// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:prime/models/user.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';
import 'package:prime/widgets/no_data_found.dart';
import 'package:provider/provider.dart';
import 'package:prime/models/car_rental.dart';
import 'package:prime/providers/car_rental_provider.dart';
import 'package:prime/providers/car_provider.dart';
import '../services/firebase/firebase_auth_service.dart';
import 'tiles/car_rental_card.dart';

class HostRentalsHistoryTabBody extends StatelessWidget {
  const HostRentalsHistoryTabBody({super.key});

  Future<List<Map<String, dynamic>>> _fetchRentalsHistory(
      BuildContext context) async {
    final currentUserId = FirebaseAuthService().currentUser?.uid ?? '';
    final carProvider = Provider.of<CarProvider>(
      context,
      listen: false,
    );
    final hostCars = await carProvider.getCarsByHostId(currentUserId);
    final carRentalProvider = Provider.of<CarRentalProvider>(
      context,
      listen: false,
    );
    final rentalsHistoryWithCars = <Map<String, dynamic>>[];

    for (var car in hostCars) {
      if (car.id != null) {
        final carRentals =
            await carRentalProvider.getCarRentalsByCarIdAndStatuses(
          car.id ?? '',
          [
            CarRentalStatus.customerCancelled,
            CarRentalStatus.hostCancelled,
            CarRentalStatus.hostConfirmedReturn,
            CarRentalStatus.adminConfirmedRefund,
            CarRentalStatus.adminConfirmedPayout,
          ],
        );

        for (var rental in carRentals) {
          rentalsHistoryWithCars.add({
            'car': car,
            'rental': rental,
          });
        }
      }
    }

    return rentalsHistoryWithCars;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchRentalsHistory(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomProgressIndicator();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const NoDataFound(
              title: 'Nothing Found',
              subTitle: 'No rental history found.',
            );
          } else {
            final rentalsHistoryWithCars = snapshot.data!;
            return ListView.builder(
              itemCount: rentalsHistoryWithCars.length,
              itemBuilder: (context, index) {
                final rentalWithCar = rentalsHistoryWithCars[index];
                return CarRentalCard(
                  carRental: rentalWithCar['rental'],
                  car: rentalWithCar['car'],
                  userRole: UserRole.host,
                );
              },
            );
          }
        },
      ),
    );
  }
}
