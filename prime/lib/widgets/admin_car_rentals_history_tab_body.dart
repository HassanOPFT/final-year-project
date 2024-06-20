import 'package:flutter/material.dart';
import 'package:prime/models/user.dart';
import 'package:prime/widgets/tiles/car_rental_card.dart';
import 'package:provider/provider.dart';

import '../models/car_rental.dart';
import '../providers/car_provider.dart';
import '../providers/car_rental_provider.dart';
import 'custom_progress_indicator.dart';
import 'no_data_found.dart';

class AdminCarRentalsHistoryTabBody extends StatelessWidget {
  const AdminCarRentalsHistoryTabBody({super.key});

  Future<List<Map<String, dynamic>>> _fetchRentalsHistory(
      BuildContext context) async {
    final carProvider = Provider.of<CarProvider>(context, listen: false);
    final carRentalProvider =
        Provider.of<CarRentalProvider>(context, listen: false);
    final rentalsHistoryWithCars = <Map<String, dynamic>>[];

    final cars = await carProvider.getAllCars();

    for (var car in cars) {
      if (car.id != null) {
        final carRentals = await carRentalProvider.getCarRentalsByStatuses(
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
                  userRole: UserRole.primaryAdmin,
                );
              },
            );
          }
        },
      ),
    );
  }
}
