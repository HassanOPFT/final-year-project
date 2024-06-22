import 'package:flutter/material.dart';
import '../models/car_rental.dart';
import '../models/user.dart';

class CarRentalStatusIndicator extends StatelessWidget {
  final CarRentalStatus carRentalStatus;
  final UserRole userRole;

  const CarRentalStatusIndicator({
    super.key,
    required this.carRentalStatus,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (carRentalStatus) {
      case CarRentalStatus.rentedByCustomer:
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade900;
        break;
      case CarRentalStatus.pickedUpByCustomer:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade900;
        break;
      case CarRentalStatus.customerReportedIssue:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade900;
        break;
      case CarRentalStatus.customerExtendedRental:
        backgroundColor = Colors.purple.shade50;
        textColor = Colors.purple.shade900;
        break;
      case CarRentalStatus.customerReturnedCar:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade900;
        break;
      case CarRentalStatus.hostConfirmedPickup:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade900;
        break;
      case CarRentalStatus.customerCancelled:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade900;
        break;
      case CarRentalStatus.hostCancelled:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade900;
        break;
      case CarRentalStatus.hostReportedIssue:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade900;
        break;
      case CarRentalStatus.hostConfirmedReturn:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade900;
        break;
      case CarRentalStatus.adminConfirmedPayout:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade900;
        break;
      case CarRentalStatus.adminConfirmedRefund:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade900;
        break;
      default:
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade900;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Text(
        carRentalStatus.getStatusString(userRole),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.0,
          color: textColor,
        ),
      ),
    );
  }
}
