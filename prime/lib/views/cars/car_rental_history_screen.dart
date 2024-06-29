import 'package:flutter/material.dart';
import 'package:prime/models/car_rental.dart';
import 'package:prime/models/user.dart';
import 'package:prime/widgets/no_data_found.dart';
import 'package:prime/widgets/tiles/car_rental_card.dart';
import 'package:provider/provider.dart';

import '../../models/car.dart';
import '../../providers/car_provider.dart';
import '../../providers/car_rental_provider.dart';
import '../../widgets/custom_progress_indicator.dart';

class CarRentalHistoryScreen extends StatelessWidget {
  final String carId;

  const CarRentalHistoryScreen({
    super.key,
    required this.carId,
  });

  Future<List<Map<String, dynamic>>> _fetchCarRentalsAndCars(
      BuildContext context) async {
    try {
      final carProvider = Provider.of<CarProvider>(context, listen: false);
      final carRentalProvider =
          Provider.of<CarRentalProvider>(context, listen: false);

      final car = await carProvider.getCarById(carId);
      final carRentals = await carRentalProvider.getCarRentalsByCarId(carId);

      final List<Map<String, dynamic>> carRentalsWithCars =
          carRentals.map((rental) {
        return {
          'car': car,
          'rental': rental,
        };
      }).toList();

      return carRentalsWithCars;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchCarRentalsAndCars(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomProgressIndicator();
            } else if (snapshot.hasError) {
              return const Center(
                  child: Text('Error fetching rental history.'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const NoDataFound(
                title: 'No History Found',
                subTitle: 'No rental history found for this car.',
              );
            } else {
              final carRentalsWithCars = snapshot.data!;
              return ListView.builder(
                itemCount: carRentalsWithCars.length,
                itemBuilder: (context, index) {
                  final rentalWithCar = carRentalsWithCars[index];
                  final Car car = rentalWithCar['car'];
                  final CarRental rental = rentalWithCar['rental'];
                  return CarRentalCard(
                    carRental: rental,
                    car: car,
                    userRole: UserRole.host,
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
