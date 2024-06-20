// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/views/rentals/confirm_car_rental_screen.dart';
import 'package:provider/provider.dart';

import '../models/verification_document.dart';
import '../providers/customer_provider.dart';
import '../providers/user_provider.dart';
import '../providers/verification_document_provider.dart';
import '../services/firebase/firebase_auth_service.dart';
import '../utils/snackbar.dart';
import 'customer_documents_rent_status_checker.dart';

class CarRentalSchedulePicker extends StatefulWidget {
  final String carId;

  final void Function() stopListeningToCarStatus;

  const CarRentalSchedulePicker({
    super.key,
    required this.carId,
    required this.stopListeningToCarStatus,
  });

  @override
  State<CarRentalSchedulePicker> createState() =>
      _CarRentalSchedulePickerState();
}

class _CarRentalSchedulePickerState extends State<CarRentalSchedulePicker> {
  DateTime? _pickUpDateTime = DateTime.now()
      .add(const Duration(hours: 1))
      .copyWith(second: 0, millisecond: 0, microsecond: 0);
  DateTime? _dropOffDateTime = DateTime.now()
      .add(const Duration(hours: 2))
      .copyWith(second: 0, millisecond: 0, microsecond: 0);

  final currentUserId = FirebaseAuthService().currentUser?.uid;

  Future<bool> hasApprovedIdentityDocument() async {
    try {
      if (currentUserId == null || currentUserId!.isEmpty) {
        return false;
      }
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );

      final identityDocumentId = await customerProvider.getIdentityDocumentId(
        currentUserId ?? '',
      );

      if (identityDocumentId.isEmpty) {
        return false;
      }

      // Check the status of the identity document
      final verificationDocumentProvider =
          Provider.of<VerificationDocumentProvider>(
        context,
        listen: false,
      );
      final identityDocument = await verificationDocumentProvider
          .getVerificationDocumentById(identityDocumentId);

      if (identityDocument == null ||
          identityDocument.status != VerificationDocumentStatus.approved) {
        // Identity document is not approved
        return false;
      }

      return true;
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<bool> hasApprovedDrivingLicenseDocument() async {
    try {
      if (currentUserId == null || currentUserId!.isEmpty) {
        return false;
      }

      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );
      final drivingLicenseId = await customerProvider.getLicenseDocumentId(
        currentUserId ?? '',
      );

      if (drivingLicenseId.isEmpty) {
        return false;
      }

      // Check the status of the driving license document
      final verificationDocumentProvider =
          Provider.of<VerificationDocumentProvider>(
        context,
        listen: false,
      );
      final drivingLicenseDocument = await verificationDocumentProvider
          .getVerificationDocumentById(drivingLicenseId);

      if (drivingLicenseDocument == null ||
          drivingLicenseDocument.status !=
              VerificationDocumentStatus.approved) {
        // driving license is not approved
        return false;
      }

      return true;
    } on Exception catch (_) {
      rethrow;
    }
  }

  // check if user has phone number in the database
  Future<bool> hasPhoneNumber() async {
    try {
      final userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );

      if (currentUserId == null || currentUserId!.isEmpty) {
        return false;
      }

      final currentUser =
          await userProvider.getUserDetails(currentUserId ?? '');

      if (currentUser == null) {
        return false;
      }

      if (currentUser.userPhoneNumber == null ||
          currentUser.userPhoneNumber!.isEmpty) {
        return false;
      }

      return true;
    } on Exception catch (_) {
      rethrow;
    }
  }

  // TODO: When a user selects dates to rent a car, the system checks for overlapping rentals and determines availability.
  // TODO: If the car is available for the selected dates, the user can proceed with the rental;
  // TODO: otherwise, they are informed of the unavailability with exact dates when it's not available.
  // TODO: don't forget to update the fetching and allowing to display cars with currently rented and has upcoming rentals, specially the stream listeners
  // TODO: car rental can be extended also, check the rental extension collection in the database
  Future<void> _continueToPayment() async {
    // check for identity and driving license documents
    final identityDocumentApproved = await hasApprovedIdentityDocument();

    if (!identityDocumentApproved) {
      buildAlertSnackbar(
        context: context,
        message: 'You need an approved identity document to rent a car.',
      );
      return;
    }
    // check license document
    final drivingLicenseDocumentApproved =
        await hasApprovedDrivingLicenseDocument();

    if (!drivingLicenseDocumentApproved) {
      buildAlertSnackbar(
        context: context,
        message: 'You need an approved driving license document to rent a car.',
      );
      return;
    }

    // check if user has phone number
    final hasPhone = await hasPhoneNumber();
    if (!hasPhone) {
      buildAlertSnackbar(
        context: context,
        message:
            'You need to add a phone number to your profile to rent a car.',
      );
      return;
    }

    if (_pickUpDateTime == null || _dropOffDateTime == null) {
      buildAlertSnackbar(
        context: context,
        message: 'Please select pick-up and drop-off dates and times.',
      );
      return;
    }

    final now = DateTime.now();

    if (_pickUpDateTime!.isBefore(now)) {
      buildAlertSnackbar(
        context: context,
        message:
            'Pick-up date and time cannot be before the current date and time.',
      );
      return;
    }

    final difference = _dropOffDateTime!.difference(_pickUpDateTime!);
    final differenceInMinutes = difference.inMinutes;

    if (differenceInMinutes < 60 || differenceInMinutes % 60 != 0) {
      buildAlertSnackbar(
        context: context,
        message:
            'The time between pick-up and drop-off must be at least 60 minutes and in whole hours.',
      );
      return;
    }

    widget.stopListeningToCarStatus();

    animatedPushNavigation(
      context: context,
      screen: ConfirmCarRentalScreen(
        carId: widget.carId,
        pickUpDateTime: _pickUpDateTime!,
        dropOffDateTime: _dropOffDateTime!,
      ),
    );
  }

  Future<void> _selectPickUpDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _pickUpDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_pickUpDateTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _pickUpDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
            0, // seconds
            0, // milliseconds
          );
          _updateDropOffDateTime();
        });
      }
    }
  }

  Future<void> _selectDropOffDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dropOffDateTime ?? _pickUpDateTime ?? DateTime.now(),
      firstDate: _pickUpDateTime ?? DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dropOffDateTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _dropOffDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
            0, // seconds
            0, // milliseconds
          );
        });
      }
    }
  }

  void _updateDropOffDateTime() {
    if (_pickUpDateTime != null && _dropOffDateTime != null) {
      if (_pickUpDateTime!.isAfter(_dropOffDateTime!)) {
        _dropOffDateTime = _pickUpDateTime!.add(const Duration(hours: 1));
      }
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Select Date and Time';
    return DateFormat('d MMM yyyy, h:mm a').format(dateTime);
  }

  Widget _buildDateTimeRow(
    String label,
    DateTime? dateTime,
    bool isPickUp,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 15.0),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(15.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              TextButton.icon(
                onPressed: isPickUp
                    ? () => _selectPickUpDateTime(context)
                    : () => _selectDropOffDateTime(context),
                icon: const Icon(Icons.calendar_today_rounded),
                label: Text(
                  _formatDateTime(dateTime),
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateTimeRow(
            'Pick-up Date & Time',
            _pickUpDateTime,
            true,
          ),
          const SizedBox(height: 30.0),
          _buildDateTimeRow(
            'Drop-off Date & Time',
            _dropOffDateTime,
            false,
          ),
          const SizedBox(height: 20.0),
          CustomerDocumentsRentStatusChecker(
            hasApprovedIdentityDocument: hasApprovedIdentityDocument,
            hasApprovedDrivingLicenseDocument:
                hasApprovedDrivingLicenseDocument,
            hasPhoneNumber: hasPhoneNumber,
          ),
          const SizedBox(height: 30.0),
          SizedBox(
            height: 50.0,
            child: FilledButton(
              onPressed: _continueToPayment,
              child: const Text(
                'Continue to Payment',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
