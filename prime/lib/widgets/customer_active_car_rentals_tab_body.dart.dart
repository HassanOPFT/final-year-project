import 'package:flutter/material.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';
import 'package:prime/widgets/no_data_found.dart';
import 'package:prime/widgets/tiles/car_rental_card.dart';
import 'package:provider/provider.dart';
import 'package:prime/models/car_rental.dart';
import 'package:prime/models/car.dart';
import 'package:prime/providers/car_rental_provider.dart';
import 'package:prime/providers/car_provider.dart';
import '../models/user.dart';
import '../services/firebase/firebase_auth_service.dart';

class CustomerActiveCarRentalsTabBody extends StatefulWidget {
  const CustomerActiveCarRentalsTabBody({super.key});

  @override
  State<CustomerActiveCarRentalsTabBody> createState() =>
      _CustomerActiveCarRentalsTabBodyState();
}

class _CustomerActiveCarRentalsTabBodyState
    extends State<CustomerActiveCarRentalsTabBody> {
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
        CarRentalStatus.rentedByCustomer,
        CarRentalStatus.pickedUpByCustomer,
        CarRentalStatus.customerReportedIssue,
        CarRentalStatus.customerExtendedRental,
        CarRentalStatus.customerReturnedCar,
        CarRentalStatus.hostConfirmedPickup,
        CarRentalStatus.hostReportedIssue,
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

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: FutureBuilder<Map<CarRental, Car>>(
          future: _fetchRentalsWithCars(context, userId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120.0),
                  NoDataFound(
                    title: 'Nothing Found',
                    subTitle: 'You have no ongoing or upcoming car rentals.',
                  ),
                ],
              );
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
      ),
    );
  }
}
