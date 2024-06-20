import 'package:flutter/material.dart';
import 'package:prime/models/user.dart';

import '../../models/car_rental.dart';

class EditCarRentalBottomSheet extends StatelessWidget {
  final UserRole userRole;
  final CarRental carRental;
  final List<CarRentalStatus?> carRentalStatusHistory;
  final Function(CarRental) pickUpByCustomer;
  final Function(CarRental) confirmPickUpByHost;
  final Function(CarRental) cancelCarRental;
  final Function(CarRental) reportIssue;
  final Function(CarRental) extendRental;
  final Function(CarRental) confirmReturnByHost;
  final Function(CarRental) returnCarByCustomer;
  final Function(CarRental) confirmPayout;
  final Function(CarRental) confirmRefund;

  const EditCarRentalBottomSheet({
    super.key,
    required this.userRole,
    required this.carRental,
    required this.carRentalStatusHistory,
    required this.pickUpByCustomer,
    required this.confirmPickUpByHost,
    required this.cancelCarRental,
    required this.reportIssue,
    required this.extendRental,
    required this.confirmReturnByHost,
    required this.returnCarByCustomer,
    required this.confirmPayout,
    required this.confirmRefund,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [];

    Widget pickUpByCustomerButton() {
      return TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          pickUpByCustomer(carRental);
        },
        icon: const Icon(Icons.directions_car),
        label: const Text(
          'Pick Up Car',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    Widget confirmPickUpByHostButton() {
      return TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          confirmPickUpByHost(carRental);
        },
        icon: const Icon(Icons.check_circle),
        label: const Text(
          'Confirm Car Pick Up',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    Widget cancelRentalButton() {
      return TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          cancelCarRental(carRental);
        },
        icon: const Icon(
          Icons.cancel_rounded,
          color: Colors.red,
        ),
        label: const Text(
          'Cancel Car Rental',
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.red,
          ),
        ),
      );
    }

    Widget reportIssueButton() {
      return TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          reportIssue(carRental);
        },
        icon: const Icon(Icons.report_problem_rounded),
        label: const Text(
          'Report Issue',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    Widget extendRentalButton() {
      return TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          extendRental(carRental);
        },
        icon: const Icon(Icons.access_time),
        label: const Text(
          'Extend Rental',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    Widget returnCarByCustomerButton() {
      return TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          returnCarByCustomer(carRental);
        },
        icon: const Icon(Icons.check_circle),
        label: const Text(
          'Return Car',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    Widget confirmCarReturnByHostButton() {
      return TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          confirmReturnByHost(carRental);
        },
        icon: const Icon(Icons.check_circle),
        label: const Text(
          'Confirm Car Return',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    Widget confirmPayoutButton() {
      return TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          confirmPayout(carRental);
        },
        icon: const Icon(Icons.check_circle),
        label: const Text(
          'Confirm Payout',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    Widget confirmRefundButton() {
      return TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          confirmRefund(carRental);
        },
        icon: const Icon(Icons.check_circle),
        label: const Text(
          'Confirm Refund',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    void loadCustomerButtons() {
      switch (carRental.status) {
        case CarRentalStatus.rentedByCustomer:
          buttons.addAll([
            pickUpByCustomerButton(),
            cancelRentalButton(),
          ]);
          break;

        case CarRentalStatus.pickedUpByCustomer:
          if (!carRentalStatusHistory
              .contains(CarRentalStatus.customerReturnedCar)) {
            buttons.addAll([
              reportIssueButton(),
              extendRentalButton(),
              returnCarByCustomerButton(),
              cancelRentalButton(),
            ]);
          }
          break;

        case CarRentalStatus.customerReportedIssue:
        case CarRentalStatus.hostReportedIssue:
          if (!carRentalStatusHistory
              .contains(CarRentalStatus.customerReturnedCar)) {
            buttons.addAll([
              returnCarByCustomerButton(),
              cancelRentalButton(),
            ]);
          }
          break;

        case CarRentalStatus.customerExtendedRental:
          if (!carRentalStatusHistory
              .contains(CarRentalStatus.customerReturnedCar)) {
            buttons.addAll([
              returnCarByCustomerButton(),
              cancelRentalButton(),
            ]);
          }
          break;

        case CarRentalStatus.customerReturnedCar:
          // No actions after car is returned
          break;

        case CarRentalStatus.hostConfirmedPickup:
          if (!carRentalStatusHistory
              .contains(CarRentalStatus.customerReturnedCar)) {
            buttons.addAll([
              reportIssueButton(),
              extendRentalButton(),
              returnCarByCustomerButton(),
              cancelRentalButton(),
            ]);
          }
          break;

        case CarRentalStatus.customerCancelled:
        case CarRentalStatus.hostCancelled:
        case CarRentalStatus.hostConfirmedReturn:
        case CarRentalStatus.adminConfirmedPayout:
        case CarRentalStatus.adminConfirmedRefund:
          // No actions after these statuses
          break;

        default:
          break;
      }
    }

    void loadHostButtons() {
      switch (carRental.status) {
        case CarRentalStatus.rentedByCustomer:
          if (!carRentalStatusHistory.contains(CarRentalStatus.hostCancelled)) {
            buttons.add(confirmPickUpByHostButton());
          }
          break;

        case CarRentalStatus.pickedUpByCustomer:
          if (!carRentalStatusHistory
              .contains(CarRentalStatus.hostConfirmedPickup)) {
            buttons.addAll([
              reportIssueButton(),
              cancelRentalButton(),
            ]);
          }
          break;

        case CarRentalStatus.customerReportedIssue:
          if (carRentalStatusHistory
                  .contains(CarRentalStatus.pickedUpByCustomer) ||
              carRentalStatusHistory
                  .contains(CarRentalStatus.customerExtendedRental) ||
              carRentalStatusHistory
                  .contains(CarRentalStatus.customerReportedIssue)) {
            buttons.addAll([
              reportIssueButton(),
              cancelRentalButton(),
            ]);
          }
          break;

        case CarRentalStatus.customerExtendedRental:
          if (!carRentalStatusHistory.contains(CarRentalStatus.hostCancelled)) {
            buttons.add(cancelRentalButton());
          }
          break;

        case CarRentalStatus.customerReturnedCar:
          if (carRentalStatusHistory
                  .contains(CarRentalStatus.pickedUpByCustomer) ||
              carRentalStatusHistory
                  .contains(CarRentalStatus.customerExtendedRental) ||
              carRentalStatusHistory
                  .contains(CarRentalStatus.customerReportedIssue) ||
              carRentalStatusHistory
                  .contains(CarRentalStatus.hostReportedIssue)) {
            buttons.add(confirmCarReturnByHostButton());
          }
          break;

        case CarRentalStatus.hostConfirmedPickup:
          if (!carRentalStatusHistory.contains(CarRentalStatus.hostCancelled)) {
            buttons.addAll([
              reportIssueButton(),
              cancelRentalButton(),
            ]);
          }
          break;

        case CarRentalStatus.customerCancelled:
        case CarRentalStatus.hostCancelled:
        case CarRentalStatus.hostReportedIssue:
        case CarRentalStatus.hostConfirmedReturn:
        case CarRentalStatus.adminConfirmedPayout:
        case CarRentalStatus.adminConfirmedRefund:
          // No actions after these statuses
          break;

        default:
          break;
      }
    }

    void loadAdminButtons() {
      switch (carRental.status) {
        case CarRentalStatus.customerCancelled:
          if (carRentalStatusHistory
                  .contains(CarRentalStatus.rentedByCustomer) ||
              carRentalStatusHistory
                  .contains(CarRentalStatus.pickedUpByCustomer) ||
              carRentalStatusHistory
                  .contains(CarRentalStatus.customerExtendedRental) ||
              carRentalStatusHistory
                  .contains(CarRentalStatus.customerReportedIssue) ||
              carRentalStatusHistory
                  .contains(CarRentalStatus.hostReportedIssue)) {
            buttons.add(confirmPayoutButton());
          }
          break;

        case CarRentalStatus.hostConfirmedReturn:
          if (carRentalStatusHistory
              .contains(CarRentalStatus.customerReturnedCar)) {
            buttons.add(confirmPayoutButton());
            buttons.add(confirmRefundButton());
          }
          break;

        case CarRentalStatus.rentedByCustomer:
        case CarRentalStatus.pickedUpByCustomer:
        case CarRentalStatus.customerReportedIssue:
        case CarRentalStatus.customerExtendedRental:
        case CarRentalStatus.customerReturnedCar:
        case CarRentalStatus.hostConfirmedPickup:
        case CarRentalStatus.hostCancelled:
        case CarRentalStatus.hostReportedIssue:
        case CarRentalStatus.adminConfirmedPayout:
        case CarRentalStatus.adminConfirmedRefund:
          // No actions allowed, can only view
          break;

        default:
          break;
      }
    }

    void loadButtonsByCarRentalStatusAndRole() {
      switch (userRole) {
        case UserRole.customer:
          loadCustomerButtons();
          break;
        case UserRole.host:
          loadHostButtons();
          break;
        case UserRole.primaryAdmin:
        case UserRole.secondaryAdmin:
          loadAdminButtons();
          break;
      }
    }

    loadButtonsByCarRentalStatusAndRole();

    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Edit Car Rental',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5.0),
          const Divider(),
          const SizedBox(height: 15.0),
          if (buttons.isEmpty)
            const Center(
              child: Text(
                'No actions available',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          if (buttons.isNotEmpty) ...buttons,
        ],
      ),
    );
  }
}
