import 'package:flutter/material.dart';
import 'package:prime/models/car_rental.dart';
import 'package:prime/models/user.dart';

class CustomerCarRentalTile extends StatelessWidget {
  final CarRental carRental;
  final UserRole userRole;

  const CustomerCarRentalTile({
    super.key,
    required this.carRental,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Car ID: ${carRental.carId ?? 'N/A'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8),
            Text('Rental ID: ${carRental.id ?? 'N/A'}'),
            Text(
                'Status: ${carRental.status?.getStatusString(userRole) ?? 'N/A'}'),
            Text('Start Date: ${carRental.startDate ?? 'N/A'}'),
            Text('End Date: ${carRental.endDate ?? 'N/A'}'),
            Text('Customer id: ${carRental.customerId ?? 'N/A'}'),
            Text('Stripe Charge ID: ${carRental.stripeChargeId ?? 'N/A'}'),
            Text('Reference No: ${carRental.referenceNumber ?? 'N/A'}'),
            Text('Extension Count: ${carRental.extensionCount ?? 'N/A'}'),
            Text('Created At: ${carRental.createdAt ?? 'N/A'}'),
            // created at
          ],
        ),
      ),
    );
  }
}
