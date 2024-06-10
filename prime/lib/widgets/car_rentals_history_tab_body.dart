import 'package:flutter/material.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';
import 'package:prime/widgets/tiles/customer_car_rental_tile.dart';
import 'package:provider/provider.dart';
import 'package:prime/models/car_rental.dart';
import 'package:prime/providers/car_rental_provider.dart';

import '../models/user.dart';
import '../services/firebase/firebase_auth_service.dart';

class CarRentalsHistoryTabBody extends StatelessWidget {
  const CarRentalsHistoryTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuthService().currentUser?.uid;

    return FutureBuilder<List<CarRental>>(
      future: Provider.of<CarRentalProvider>(context, listen: false)
          .getCarRentalsByCustomerIdAndStatuses(
        userId!,
        [
          CarRentalStatus.hostConfirmedReturn,
          CarRentalStatus.adminConfirmedPayment,
          CarRentalStatus.customerCancelled,
        ],
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomProgressIndicator();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No rental history found.'));
        } else {
          final rentals = snapshot.data!;
          return ListView.builder(
            itemCount: rentals.length,
            itemBuilder: (context, index) {
              return CustomerCarRentalTile(
                carRental: rentals[index],
                userRole: UserRole.customer,
              );
            },
          );
        }
      },
    );
  }
}
