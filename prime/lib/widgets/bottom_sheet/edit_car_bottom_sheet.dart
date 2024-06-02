import 'package:flutter/material.dart';
import '../../models/car.dart';

class EditCarBottomSheet extends StatelessWidget {
  final bool isAdmin;
  final Car car;
  final Function(Car) approveCar;
  final Function(Car) rejectCar;
  final Function(Car) haltCar;
  final Function(Car) deleteCar;
  final Function(Car) requestUnhaltCar;
  final Function(Car) unhaltCar;
  final Function(Car) updateCar;

  const EditCarBottomSheet({
    super.key,
    required this.isAdmin,
    required this.car,
    required this.approveCar,
    required this.rejectCar,
    required this.haltCar,
    required this.deleteCar,
    required this.requestUnhaltCar,
    required this.unhaltCar,
    required this.updateCar,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [];

    Widget approveCarButton() {
      return TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          approveCar(car);
        },
        icon: const Icon(Icons.check_circle_rounded),
        label: const Text(
          'Approve Car',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    Widget rejectCarButton() {
      return TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          rejectCar(car);
        },
        icon: const Icon(Icons.cancel_rounded),
        label: const Text(
          'Reject Car',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    Widget haltCarButton() {
      return TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          haltCar(car);
        },
        icon: const Icon(Icons.pause_rounded),
        label: const Text(
          'Halt Car',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    Widget deleteCarButton() {
      return TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          deleteCar(car);
        },
        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
        label: const Text(
          'Delete Car',
          style: TextStyle(fontSize: 18.0, color: Colors.red),
        ),
      );
    }

    Widget requestUnhaltCarButton() {
      return TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          requestUnhaltCar(car);
        },
        icon: const Icon(Icons.play_circle_filled_rounded),
        label: const Text(
          'Request Unhalt Car',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    Widget unhaltCarButton() {
      return TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          unhaltCar(car);
        },
        icon: const Icon(Icons.play_circle_filled_rounded),
        label: const Text(
          'Unhalt Car',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    Widget updateCarButton() {
      return TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          updateCar(car);
        },
        icon: const Icon(Icons.edit),
        label: const Text(
          'Update Car',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    void loadButtonsByCarStatusAndRole() {
      switch (car.status) {
        case CarStatus.currentlyRented:
          if (isAdmin) {
            // no buttons for currentlyRented
          } else {
            // no buttons for currentlyRented
          }
          break;

        case CarStatus.upcomingRental:
          if (isAdmin) {
            // no buttons for upcomingRental
          } else {
            // no buttons for upcomingRental
          }
          break;

        case CarStatus.uploaded:
          if (isAdmin) {
            // Approve, Reject, Halt, Delete
            buttons.addAll(
              [
                approveCarButton(),
                rejectCarButton(),
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          } else {
            // update, halt, delete
            buttons.addAll(
              [
                updateCarButton(),
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          }
          break;

        case CarStatus.pendingApproval:
          if (isAdmin) {
            // Approve, Reject, Halt, Delete
            buttons.addAll(
              [
                approveCarButton(),
                rejectCarButton(),
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          } else {
            // update, halt, delete
            buttons.addAll(
              [
                updateCarButton(),
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          }
          break;

        case CarStatus.updated:
          if (isAdmin) {
            // Approve, Reject, Halt, Delete
            buttons.addAll(
              [
                approveCarButton(),
                rejectCarButton(),
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          } else {
            // update, halt, delete
            buttons.addAll(
              [
                updateCarButton(),
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          }
          break;

        case CarStatus.approved:
          if (isAdmin) {
            // halt, delete
            buttons.addAll(
              [
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          } else {
            // update, halt, delete
            buttons.addAll(
              [
                updateCarButton(),
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          }
          break;

        case CarStatus.rejected:
          if (isAdmin) {
            // approve, halt, delete
            buttons.addAll(
              [
                approveCarButton(),
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          } else {
            // update, halt, delete
            buttons.addAll(
              [
                updateCarButton(),
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          }
          break;

        case CarStatus.haltedByHost:
          if (isAdmin) {
            // halt, delete
            buttons.addAll(
              [
                haltCarButton(),
                deleteCarButton(),
              ],
            );
          } else {
            // unhalt, delete
            buttons.addAll(
              [
                unhaltCarButton(),
                deleteCarButton(),
              ],
            );
          }
          break;

        case CarStatus.haltedByAdmin:
          if (isAdmin) {
            // unhalt, delete
            buttons.addAll(
              [
                unhaltCarButton(),
                deleteCarButton(),
              ],
            );
          } else {
            // update, request unhalt, delete
            buttons.addAll(
              [
                updateCarButton(),
                requestUnhaltCarButton(),
                deleteCarButton(),
              ],
            );
          }
          break;

        case CarStatus.unhaltRequested:
          if (isAdmin) {
            // unhalt, delete
            buttons.addAll(
              [
                unhaltCarButton(),
                deleteCarButton(),
              ],
            );
          } else {
            // update, delete
            buttons.addAll(
              [
                updateCarButton(),
                deleteCarButton(),
              ],
            );
          }
          break;

        case CarStatus.deletedByHost:
          if (isAdmin) {
            // delete
            buttons.add(
              deleteCarButton(),
            );
          } else {
            // no buttons for deletedByHost for non admin
          }
          break;

        case CarStatus.deletedByAdmin:
          if (isAdmin) {
            // no buttons for deletedByAdmin for admin
          } else {
            // no buttons for deletedByAdmin for non admin
          }
          break;

        default:
          break;
      }
    }

    loadButtonsByCarStatusAndRole();

    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Edit Car',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5.0),
          const Divider(),
          const SizedBox(height: 15.0),
          ...buttons,
        ],
      ),
    );
  }
}
