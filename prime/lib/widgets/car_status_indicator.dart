import 'package:flutter/material.dart';
import '../models/car.dart';

class CarStatusIndicator extends StatelessWidget {
  final CarStatus carStatus;

  const CarStatusIndicator({
    super.key,
    required this.carStatus,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (carStatus) {
      case CarStatus.currentlyRented:
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade900;
        break;
      case CarStatus.upcomingRental:
        backgroundColor = Colors.purple.shade50;
        textColor = Colors.purple.shade900;
        break;
      case CarStatus.uploaded:
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade900;
        break;
      case CarStatus.pendingApproval:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade900;
        break;
      case CarStatus.updated:
        backgroundColor = Colors.yellow.shade50;
        textColor = Colors.yellow.shade900;
        break;
      case CarStatus.approved:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade900;
        break;
      case CarStatus.rejected:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade900;
        break;
      case CarStatus.haltedByHost:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade900;
        break;
      case CarStatus.haltedByAdmin:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade900;
        break;
      case CarStatus.unhaltRequested:
        backgroundColor = Colors.purple.shade50;
        textColor = Colors.purple.shade900;
        break;
      case CarStatus.deletedByHost:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade900;
        break;
      case CarStatus.deletedByAdmin:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade900;
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
        carStatus.getCarStatusString(),
        style: TextStyle(
          fontSize: 16.0,
          color: textColor,
        ),
      ),
    );
  }
}
