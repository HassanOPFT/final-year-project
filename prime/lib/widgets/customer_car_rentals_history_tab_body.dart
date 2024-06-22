import 'package:flutter/material.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';
import 'package:prime/widgets/tiles/car_rental_card.dart';
import 'package:provider/provider.dart';
import 'package:prime/models/car_rental.dart';
import 'package:prime/providers/car_rental_provider.dart';

import '../models/car.dart';
import '../models/user.dart';
import '../providers/car_provider.dart';
import '../services/firebase/firebase_auth_service.dart';
import 'no_data_found.dart';

class CustomerCarRentalsHistoryTabBody extends StatelessWidget {
  const CustomerCarRentalsHistoryTabBody({super.key});

  Future<Map<CarRental, Car>> _fetchRentalsWithCars(
    BuildContext context,
    String userId,
  ) async {
    final carRentalProvider = Provider.of<CarRentalProvider>(
      context,
      listen: false,
    );
    final carProvider = Provider.of<CarProvider>(
      context,
      listen: false,
    );

    final rentals =
        await carRentalProvider.getCarRentalsByCustomerIdAndStatuses(
      userId,
      [
        CarRentalStatus.hostConfirmedReturn,
        CarRentalStatus.adminConfirmedPayout,
        CarRentalStatus.adminConfirmedRefund,
        CarRentalStatus.customerCancelled,
        CarRentalStatus.hostCancelled,
      ],
    );

    final carFutures = rentals
        .map((rental) => carProvider.getCarById(rental.carId ?? ''))
        .toList();
    final cars = await Future.wait(carFutures);

    final Map<CarRental, Car> rentalsWithCars = {};
    for (int i = 0; i < rentals.length; i++) {
      if (cars[i] != null) {
        rentalsWithCars[rentals[i]] = cars[i]!;
      }
    }
    return rentalsWithCars;
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuthService().currentUser?.uid;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: FutureBuilder<Map<CarRental, Car>>(
        future: _fetchRentalsWithCars(context, userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomProgressIndicator();
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error: while loading rental history. please try again later.',
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const NoDataFound(
              title: 'Nothing Found',
              subTitle: 'You have no rental history.',
            );
            ;
          } else {
            final rentalsWithCars = snapshot.data!;
            return ListView.builder(
              itemCount: rentalsWithCars.length,
              itemBuilder: (context, index) {
                final carRental = rentalsWithCars.keys.elementAt(index);
                final car = rentalsWithCars.values.elementAt(index);
                return CarRentalCard(
                  carRental: carRental,
                  car: car,
                  userRole: UserRole.customer,
                );
              },
            );
          }
        },
      ),
    );
  }
}
