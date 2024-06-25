import 'package:flutter/material.dart';
import 'package:prime/models/user.dart';
import 'package:prime/widgets/tiles/car_rental_card.dart';
import 'package:provider/provider.dart';

import '../models/car_rental.dart';
import '../providers/car_provider.dart';
import '../providers/car_rental_provider.dart';
import 'custom_progress_indicator.dart';
import 'no_data_found.dart';

class AdminActiveCarRentalsTabBody extends StatelessWidget {
  const AdminActiveCarRentalsTabBody({super.key});

  Future<List<Map<String, dynamic>>> _fetchActiveRentals(
      BuildContext context) async {
    final carProvider = Provider.of<CarProvider>(context, listen: false);
    final carRentalProvider =
        Provider.of<CarRentalProvider>(context, listen: false);
    final activeRentalsWithCars = <Map<String, dynamic>>[];

    final carRentals = await carRentalProvider.getCarRentalsByStatuses(
      [
        CarRentalStatus.rentedByCustomer,
        CarRentalStatus.pickedUpByCustomer,
        CarRentalStatus.hostReportedIssue,
        CarRentalStatus.hostConfirmedPickup,
        CarRentalStatus.customerReturnedCar,
        CarRentalStatus.customerReportedIssue,
        CarRentalStatus.customerExtendedRental,
      ],
    );
    for (var carRental in carRentals) {
      if (carRental.carId != null) {
        final car = await carProvider.getCarById(carRental.carId!);
        activeRentalsWithCars.add({
          'car': car,
          'rental': carRental,
        });
      }
    }

    return activeRentalsWithCars;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchActiveRentals(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomProgressIndicator();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const NoDataFound(
              title: 'Nothing Found',
              subTitle: 'No active rentals found.',
            );
          } else {
            final activeRentalsWithCars = snapshot.data!;
            return ListView.builder(
              itemCount: activeRentalsWithCars.length,
              itemBuilder: (context, index) {
                final rentalWithCar = activeRentalsWithCars[index];
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
