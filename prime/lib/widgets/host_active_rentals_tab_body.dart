// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:prime/models/user.dart';
import 'package:prime/widgets/tiles/car_rental_card.dart';
import 'package:provider/provider.dart';

import '../models/car_rental.dart';
import '../providers/car_provider.dart';
import '../providers/car_rental_provider.dart';
import '../services/firebase/firebase_auth_service.dart';
import 'custom_progress_indicator.dart';
import 'no_data_found.dart';

class HostActiveRentalsTabBody extends StatefulWidget {
  const HostActiveRentalsTabBody({super.key});

  @override
  State<HostActiveRentalsTabBody> createState() =>
      _HostActiveRentalsTabBodyState();
}

class _HostActiveRentalsTabBodyState extends State<HostActiveRentalsTabBody> {
  Future<List<Map<String, dynamic>>> _fetchActiveRentals(
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
    final activeRentalsWithCars = <Map<String, dynamic>>[];

    for (var car in hostCars) {
      if (car.id != null) {
        final carRentals =
            await carRentalProvider.getCarRentalsByCarIdAndStatuses(
          car.id ?? '',
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

        for (var rental in carRentals) {
          activeRentalsWithCars.add({
            'car': car,
            'rental': rental,
          });
        }
      }
    }

    return activeRentalsWithCars;
  }

  @override
  Widget build(BuildContext context) {
    // update when car rental is updated
    Provider.of<CarRentalProvider>(context);
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchActiveRentals(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomProgressIndicator();
            } else if (snapshot.hasError) {
              return const Center(
                  child: Text('Error fetching active rentals.'));
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
