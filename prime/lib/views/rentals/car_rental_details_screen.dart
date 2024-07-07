// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/models/stripe_charge.dart';
import 'package:prime/models/stripe_transaction.dart';
import 'package:prime/providers/issue_report_provider.dart';
import 'package:prime/services/firebase/firebase_auth_service.dart';
import 'package:prime/services/stripe/stripe_transaction_service.dart';
import 'package:prime/utils/launch_core_service_util.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/views/cars/manage_car_screen.dart';
import 'package:prime/views/rentals/preview_car_details.dart';
import 'package:prime/widgets/bottom_sheet/review_car_rental_bottom_sheet.dart';
import 'package:prime/widgets/car_rental_latest_issue_report.dart';
import 'package:prime/widgets/car_rental_latest_status_history_record.dart';
import 'package:prime/widgets/car_rental_status_indicator.dart';
import 'package:prime/widgets/created_at_row.dart';
import 'package:prime/widgets/reference_number_row.dart';
import 'package:provider/provider.dart';

import '../../models/address.dart';
import '../../models/car.dart';
import '../../models/car_rental.dart';
import '../../models/issue_report.dart';
import '../../models/status_history.dart';
import '../../models/user.dart';
import '../../providers/address_provider.dart';
import '../../providers/car_provider.dart';
import '../../providers/car_rental_provider.dart';
import '../../providers/status_history_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/stripe/stripe_charge_service.dart';
import '../../utils/snackbar.dart';
import '../../widgets/bottom_sheet/edit_car_rental_bottom_sheet.dart';
import '../../widgets/custom_progress_indicator.dart';
import '../../widgets/images/car_address_image_preview.dart';
import '../../widgets/tiles/car_rental_payment_card_tile.dart';
import '../admin/user_details_screen.dart';

class CarRentalDetailsScreen extends StatefulWidget {
  final String carRentalId;
  const CarRentalDetailsScreen({
    super.key,
    required this.carRentalId,
  });

  @override
  State<CarRentalDetailsScreen> createState() => _CarRentalDetailsScreenState();
}

class _CarRentalDetailsScreenState extends State<CarRentalDetailsScreen> {
  Future<Map<String, dynamic>> _fetchAllDetails(
    BuildContext context,
    String carRentalId,
  ) async {
    final carRental = await _fetchCarRental(
      context,
      carRentalId,
    );
    final car = await _fetchCar(
      context,
      carRental?.carId ?? '',
    );
    final address = await _fetchAddress(
      context,
      car?.defaultAddressId ?? '',
    );

    final host = await _fetchUser(
      context,
      car?.hostId ?? '',
    );
    final stripeCharge = await _fetchStripeCharge(
      context,
      carRental?.stripeChargeId ?? '',
    );
    final currentUser = await _fetchCurrentUser(context);

    final carRentalStatusHistory = await _fetchCarRentalStatusHistory(
      context,
      carRentalId,
    );

    final customer = await _fetchUser(
      context,
      carRental?.customerId ?? '',
    );

    final UserRole currentUserRole = await getCurrentUserRole(
      currentUser?.userId ?? '',
      car?.hostId ?? '',
      carRental!,
      context,
    );

    final stripeTransaction = await _getStripeTransactionDetails(
      stripeCharge.balanceTransactionId ?? '',
    );

    final latestIssueReport = await _fetchLatestIssueReport(
      context,
      carRentalId,
    );

    return {
      'carRental': carRental,
      'car': car,
      'address': address,
      'host': host,
      'stripeCharge': stripeCharge,
      'currentUser': currentUser,
      'carRentalStatusHistory': carRentalStatusHistory,
      'customer': customer,
      'currentUserRole': currentUserRole,
      'stripeTransaction': stripeTransaction,
      'latestIssueReport': latestIssueReport,
    };
  }

  Future<CarRental?> _fetchCarRental(
    BuildContext context,
    String carRentalId,
  ) async {
    final carRentalProvider = Provider.of<CarRentalProvider>(
      context,
    );
    return await carRentalProvider.getCarRentalById(carRentalId);
  }

  Future<Car?> _fetchCar(
    BuildContext context,
    String? carId,
  ) async {
    final carProvider = Provider.of<CarProvider>(
      context,
      listen: false,
    );
    return await carProvider.getCarById(carId ?? '');
  }

  Future<Address?> _fetchAddress(
      BuildContext context, String? addressId) async {
    final addressProvider = Provider.of<AddressProvider>(
      context,
      listen: false,
    );
    return await addressProvider.getAddressById(addressId ?? '');
  }

  Future<User?> _fetchUser(
    BuildContext context,
    String? userId,
  ) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    return await userProvider.getUserDetails(userId ?? '');
  }

  Future<StripeCharge> _fetchStripeCharge(
    BuildContext context,
    String? stripeChargeId,
  ) async {
    final stripeCharge = StripeChargeService();
    return await stripeCharge.getChargeDetails(chargeId: stripeChargeId ?? '');
  }

  Future<User?> _fetchCurrentUser(BuildContext context) async {
    final currentUserId = FirebaseAuthService().currentUser?.uid ?? '';
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final currentUser = await userProvider.getUserDetails(currentUserId);
    return currentUser;
  }

  Future<List<CarRentalStatus?>> _fetchCarRentalStatusHistory(
    BuildContext context,
    String carRentalId,
  ) async {
    final statusHistoryProvider = Provider.of<StatusHistoryProvider>(
      context,
      listen: false,
    );
    final statusHistoryList = await statusHistoryProvider.getStatusHistoryList(
      carRentalId,
    );

    final carRentalStatusHistory = statusHistoryList.map((statusHistory) {
      if (statusHistory.newStatus == null || statusHistory.newStatus!.isEmpty) {
        return null;
      }
      return CarRentalStatusExtension.fromString(statusHistory.newStatus!);
    }).toList();

    return carRentalStatusHistory;
  }

  Future<StripeTransaction> _getStripeTransactionDetails(
    String transactionId,
  ) async {
    final stripeTransactionService = StripeTransactionService();
    final stripeTransaction =
        await stripeTransactionService.getBalanceTransactionDetails(
      transactionId: transactionId,
    );

    return stripeTransaction;
  }

  Future<IssueReport?> _fetchLatestIssueReport(
    BuildContext context,
    String carRentalId,
  ) async {
    final issueReportProvider = Provider.of<IssueReportProvider>(
      context,
      listen: false,
    );
    final latestIssueReport =
        await issueReportProvider.getLatestIssueReportByCarRentalId(
      carRentalId,
    );

    return latestIssueReport;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22.0,
        ),
      ),
    );
  }

  Widget _buildIconTextRow(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 5.0),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  Widget _buildIconTextRowWithDate(
    BuildContext context,
    IconData icon,
    String label,
    DateTime dateTime,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8.0),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
        const Spacer(),
        Text(
          DateFormat.yMMMd().add_jm().format(dateTime),
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  Widget buildPricingDetailsRow(
    String title,
    double amount, {
    FontWeight? fontWeight,
    double? fontSize = 16.0,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
          Text(
            'RM${amount.toString()}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAdminPricingDetails(
    double totalAmount,
    double hostEarnings,
    double stripeFees,
    double platformNetProfit,
  ) {
    return Column(
      children: [
        const Divider(thickness: 0.3),
        buildPricingDetailsRow(
          'Total',
          totalAmount,
        ),
        buildPricingDetailsRow(
          'Host Earnings',
          hostEarnings,
        ),
        buildPricingDetailsRow(
          'Stripe Fees',
          stripeFees,
        ),
        const Divider(thickness: 0.3),
        buildPricingDetailsRow(
          'Net Profit',
          platformNetProfit,
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
        ),
      ],
    );
  }

  Widget buildHostPricingDetails(
    double totalAmount,
    double platformNetProfit,
    double hostEarnings,
  ) {
    return Column(
      children: [
        const Divider(thickness: 0.3),
        buildPricingDetailsRow(
          'Total',
          totalAmount,
        ),
        buildPricingDetailsRow(
          'Platform Fees',
          platformNetProfit,
        ),
        const Divider(thickness: 0.3),
        buildPricingDetailsRow(
          'Host Earnings',
          hostEarnings,
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
        ),
      ],
    );
  }

  Widget buildCustomerPricingDetails(
    double totalAmount,
  ) {
    return Column(
      children: [
        const Divider(thickness: 0.3),
        buildPricingDetailsRow(
          'Total',
          totalAmount,
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
        ),
      ],
    );
  }

  Future<UserRole> getCurrentUserRole(
    String currentUserId,
    String carHostId,
    CarRental carRental,
    BuildContext context,
  ) async {
    UserRole? currentUserRole;
    if (currentUserId == carHostId) {
      currentUserRole = UserRole.host;
    } else if (currentUserId == carRental.customerId) {
      currentUserRole = UserRole.customer;
    } else {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userRole = await userProvider.getUserRole(currentUserId);
      if (userRole == UserRole.primaryAdmin ||
          userRole == UserRole.secondaryAdmin) {
        currentUserRole = userRole;
      }
    }

    // throw error if currentUserRole is null
    if (currentUserRole == null) {
      throw Exception('Error getting current user role. user role is null.');
    }
    return currentUserRole;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuthService().currentUser?.uid ?? '';

    final carRentalProvider = Provider.of<CarRentalProvider>(
      context,
      listen: false,
    );

    Future<StatusHistory?> getMostRecentStatusHistory(
      String? carRentalId,
    ) async {
      if (carRentalId == null || carRentalId.isEmpty) {
        return null;
      }
      try {
        final statusHistoryProvider = Provider.of<StatusHistoryProvider>(
          context,
        );
        final mostRecentStatusHistory =
            await statusHistoryProvider.getMostRecentStatusHistory(
          carRentalId,
        );
        return mostRecentStatusHistory;
      } catch (_) {
        return null;
      }
    }

    Future<bool?> showConfirmationDialog(
      String title,
      String message,
    ) async {
      return showDialog<bool?>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text('$message this action is irreversible.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    }

    Future<void> pickUpByCustomer(CarRental carRental) async {
      final confirmAction = await showConfirmationDialog(
        'Confirm Pick-Up',
        'Are you sure you want to confirm pick-up by customer?',
      );
      if (confirmAction == null || !confirmAction) {
        return;
      }

      try {
        await carRentalProvider.updateCarRentalStatus(
          carRentalId: widget.carRentalId,
          previousStatus: carRental.status ?? CarRentalStatus.rentedByCustomer,
          newStatus: CarRentalStatus.pickedUpByCustomer,
          modifiedById: currentUserId,
        );
        // update the car status to currently rented
        final carProvider = Provider.of<CarProvider>(
          context,
          listen: false,
        );
        carProvider.updateCarStatus(
          carId: carRental.carId ?? '',
          previousStatus: CarStatus.upcomingRental,
          newStatus: CarStatus.currentlyRented,
          modifiedById: currentUserId,
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Pick-up confirmed successfully.',
        );
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message:
              'Error confirming pick-up by customer. Please try again later.',
        );
      }
    }

    Future<void> confirmPickUpByHost(CarRental carRental) async {
      final confirmAction = await showConfirmationDialog(
        'Confirm Pick-Up',
        'Are you sure you want to confirm pick-up by host?',
      );
      if (confirmAction == null || !confirmAction) {
        return;
      }

      try {
        await carRentalProvider.updateCarRentalStatus(
          carRentalId: widget.carRentalId,
          previousStatus: carRental.status ?? CarRentalStatus.rentedByCustomer,
          newStatus: CarRentalStatus.hostConfirmedPickup,
          modifiedById: currentUserId,
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Pick-up confirmed successfully.',
        );
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error confirming pick-up by host. Please try again later.',
        );
      }
    }

    Future<String?> showReasonDialog({
      required String title,
      required String hintText,
    }) async {
      final TextEditingController reasonController = TextEditingController();
      final formKey = GlobalKey<FormState>();

      return showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(title),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: reasonController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        labelText: hintText,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().isEmpty) {
                          return 'Please enter a reason.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        if (formKey.currentState!.validate()) {
                          Navigator.of(context).pop(reasonController.text);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop(reasonController.text);
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );
    }

    Future<void> cancelCarRental(CarRental carRental) async {
      final carProvider = Provider.of<CarProvider>(context, listen: false);
      final car = await carProvider.getCarById(carRental.carId ?? '');
      final currentUserRole = await getCurrentUserRole(
        currentUserId,
        car?.hostId ?? '',
        carRental,
        context,
      );

      if (currentUserRole == UserRole.primaryAdmin ||
          currentUserRole == UserRole.secondaryAdmin) {
        buildAlertSnackbar(
          context: context,
          message: 'Cancellation is not allowed for admin.',
        );
        return;
      }

      final dialogMessage = currentUserRole == UserRole.host
          ? 'Are you sure you want to cancel this car rental? you will not be paid and customer will be fully refunded.'
          : 'Are you sure you want to cancel this car rental? you will not be refunded.';

      final confirmAction = await showConfirmationDialog(
        'Confirm Cancellation',
        dialogMessage,
      );

      if (confirmAction == null || !confirmAction) {
        return;
      }

      final cancellationReason = await showReasonDialog(
        title: 'Reason for Cancellation',
        hintText: 'Enter reason for cancellation',
      );

      if (cancellationReason == null || cancellationReason.isEmpty) {
        return;
      }

      try {
        // cancelled by host or by customer
        final CarRentalStatus newStatus = currentUserRole == UserRole.host
            ? CarRentalStatus.hostCancelled
            : CarRentalStatus.customerCancelled;
        await carRentalProvider.updateCarRentalStatus(
          carRentalId: widget.carRentalId,
          previousStatus: carRental.status ?? CarRentalStatus.rentedByCustomer,
          newStatus: newStatus,
          statusDescription: cancellationReason,
          modifiedById: currentUserId,
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Car rental cancelled successfully.',
        );
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error cancelling car rental. Please try again later.',
        );
      }
    }

    Future<Map<String, String>?> showIssueReportDialog({
      required String title,
      required String subjectHintText,
      required String descriptionHintText,
    }) async {
      final TextEditingController subjectController = TextEditingController();
      final TextEditingController descriptionController =
          TextEditingController();
      final formKey = GlobalKey<FormState>();

      return showDialog<Map<String, String>>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: subjectController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          labelText: subjectHintText,
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.trim().isEmpty) {
                            return 'Please enter a subject.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: descriptionController,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          labelText: descriptionHintText,
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.trim().isEmpty) {
                            return 'Please enter a description.';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          if (formKey.currentState!.validate()) {
                            Navigator.of(context).pop({
                              'subject': subjectController.text,
                              'description': descriptionController.text,
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop({
                      'subject': subjectController.text,
                      'description': descriptionController.text,
                    });
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );
    }

    Future<void> reportIssue(CarRental carRental) async {
      final carProvider = Provider.of<CarProvider>(context, listen: false);
      final car = await carProvider.getCarById(carRental.carId ?? '');
      final currentUserRole = await getCurrentUserRole(
        currentUserId,
        car?.hostId ?? '',
        carRental,
        context,
      );

      if (currentUserRole == UserRole.primaryAdmin ||
          currentUserRole == UserRole.secondaryAdmin) {
        buildAlertSnackbar(
          context: context,
          message: 'Reporting issue is not allowed for admin.',
        );
        return;
      }

      final issueReportDetails = await showIssueReportDialog(
        title: 'Report Issue',
        subjectHintText: 'Enter issue subject',
        descriptionHintText: 'Enter issue description',
      );

      if (issueReportDetails == null ||
          issueReportDetails['subject'] == null ||
          issueReportDetails['description'] == null ||
          issueReportDetails['subject']!.isEmpty ||
          issueReportDetails['description']!.isEmpty) {
        return;
      }

      try {
        final issueReportProvider = Provider.of<IssueReportProvider>(
          context,
          listen: false,
        );
        await issueReportProvider.createIssueReport(
          carRentalId: widget.carRentalId,
          reporterId: currentUserId,
          reportSubject: issueReportDetails['subject']!,
          reportDescription: issueReportDetails['description']!,
        );

        final newStatus = currentUserRole == UserRole.host
            ? CarRentalStatus.hostReportedIssue
            : CarRentalStatus.customerReportedIssue;

        await carRentalProvider.updateCarRentalStatus(
          carRentalId: widget.carRentalId,
          previousStatus: carRental.status ?? CarRentalStatus.rentedByCustomer,
          newStatus: newStatus,
          modifiedById: currentUserId,
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Issue reported successfully.',
        );
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error reporting issue. Please try again later.',
        );
      }
    }

    Future<void> extendRental(CarRental carRental) async {
      final confirmAction = await showConfirmationDialog(
        'Confirm Extension',
        'Are you sure you want to extend this rental?',
      );
      if (confirmAction == null || !confirmAction) {
        return;
      }

      try {
        await carRentalProvider.updateCarRentalStatus(
          carRentalId: widget.carRentalId,
          previousStatus: carRental.status ?? CarRentalStatus.rentedByCustomer,
          newStatus: CarRentalStatus.customerExtendedRental,
          modifiedById: currentUserId,
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Rental extended successfully.',
        );
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error extending rental. Please try again later.',
        );
      }
    }

    Future<void> confirmReturnByHost(CarRental carRental) async {
      final confirmAction = await showConfirmationDialog(
        'Confirm Return',
        'Are you sure you want to confirm return by host?',
      );
      if (confirmAction == null || !confirmAction) {
        return;
      }

      try {
        await carRentalProvider.updateCarRentalStatus(
          carRentalId: widget.carRentalId,
          previousStatus: carRental.status ?? CarRentalStatus.rentedByCustomer,
          newStatus: CarRentalStatus.hostConfirmedReturn,
          modifiedById: currentUserId,
        );
        // // update the car status to available
        // final carProvider = Provider.of<CarProvider>(
        //   context,
        //   listen: false,
        // );
        // carProvider.updateCarStatus(
        //   carId: carRental.carId ?? '',
        //   previousStatus: CarStatus.currentlyRented,
        //   newStatus: CarStatus.approved,
        //   modifiedById: currentUserId,
        // );
        buildSuccessSnackbar(
          context: context,
          message: 'Return confirmed successfully.',
        );
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error confirming return by host. Please try again later.',
        );
      }
    }

    Future<void> returnCarByCustomer(
      CarRental carRental,
      double rentalTotalAmount,
      Car car,
    ) async {
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        showDragHandle: true,
        enableDrag: true,
        barrierLabel: 'Address Details',
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              20.0,
              0.0,
              20.0,
              MediaQuery.of(context).viewInsets.bottom + 20.0,
            ),
            child: ReviewCarRentalBottomSheet(
              carImageUrl: car.imagesUrl?.first ?? '',
              carName: '${car.manufacturer} ${car.model}',
              carColor: '${car.color}',
              rentalTotalAmount: rentalTotalAmount.toString(),
            ),
          );
        },
      );

      if (result == null) {
        return;
      }

      final int rating = result['rating'];
      final String? review = result['review'];

      try {
        await carRentalProvider.updateCarRentalStatus(
          carRentalId: widget.carRentalId,
          previousStatus: carRental.status ?? CarRentalStatus.rentedByCustomer,
          newStatus: CarRentalStatus.customerReturnedCar,
          modifiedById: currentUserId,
        );
        // Handle the rating and review here
        await carRentalProvider.updateCarRentalReviewAndRating(
          carRentalId: widget.carRentalId,
          rating: rating.toDouble(),
          review: review,
        );

        buildSuccessSnackbar(
          context: context,
          message: 'Return confirmed successfully.',
        );
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message:
              'Error confirming return by customer. Please try again later.',
        );
      }
    }

    Future<void> confirmPayout(CarRental carRental) async {
      final confirmAction = await showConfirmationDialog(
        'Confirm Payout',
        'Are you sure you want to confirm payout?',
      );
      if (confirmAction == null || !confirmAction) {
        return;
      }

      try {
        await carRentalProvider.updateCarRentalStatus(
          carRentalId: widget.carRentalId,
          previousStatus: carRental.status ?? CarRentalStatus.rentedByCustomer,
          newStatus: CarRentalStatus.adminConfirmedPayout,
          statusDescription:
              'The payout has been confirmed & sent to the host.',
          modifiedById: currentUserId,
        );
        // update the car status to available
        final carProvider = Provider.of<CarProvider>(
          context,
          listen: false,
        );
        carProvider.updateCarStatus(
          carId: carRental.carId ?? '',
          previousStatus: CarStatus.currentlyRented,
          newStatus: CarStatus.approved,
          modifiedById: currentUserId,
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Payout confirmed successfully.',
        );
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error confirming payout. Please try again later.',
        );
      }
    }

    Future<void> confirmRefund(CarRental carRental) async {
      final confirmAction = await showConfirmationDialog(
        'Confirm Refund',
        'Are you sure you want to confirm refund?',
      );
      if (confirmAction == null || !confirmAction) {
        return;
      }

      try {
        await carRentalProvider.updateCarRentalStatus(
          carRentalId: widget.carRentalId,
          previousStatus: carRental.status ?? CarRentalStatus.rentedByCustomer,
          newStatus: CarRentalStatus.adminConfirmedRefund,
          statusDescription:
              'The refund has been confirmed & sent to the customer.',
          modifiedById: currentUserId,
        );
        // update the car status to available
        final carProvider = Provider.of<CarProvider>(
          context,
          listen: false,
        );
        carProvider.updateCarStatus(
          carId: carRental.carId ?? '',
          previousStatus: CarStatus.currentlyRented,
          newStatus: CarStatus.approved,
          modifiedById: currentUserId,
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Refund confirmed successfully.',
        );
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Error confirming refund. Please try again later.',
        );
      }
    }

    Future<void> showEditCarRentalBottomSheet(
      BuildContext context,
      CarRental carRental,
      List<CarRentalStatus?> carRentalStatusHistory,
      Car car,
      double rentalTotalAmount,
    ) async {
      if (carRental.status == null ||
          carRentalStatusHistory.isEmpty ||
          carRentalStatusHistory.contains(null)) {
        buildAlertSnackbar(
          context: context,
          message: 'Error while editing car rental. Please try again later.',
        );
        return;
      }

      UserRole? currentUserRole;
      final currentUserId = FirebaseAuthService().currentUser?.uid ?? '';
      currentUserRole = await getCurrentUserRole(
        currentUserId,
        car.hostId ?? '',
        carRental,
        context,
      );

      await showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (BuildContext context) {
          return EditCarRentalBottomSheet(
            userRole: currentUserRole!,
            carRental: carRental,
            carRentalStatusHistory: carRentalStatusHistory,
            rentalTotalAmount: rentalTotalAmount,
            car: car,
            pickUpByCustomer: pickUpByCustomer,
            confirmPickUpByHost: confirmPickUpByHost,
            cancelCarRental: cancelCarRental,
            reportIssue: reportIssue,
            extendRental: extendRental,
            confirmReturnByHost: confirmReturnByHost,
            returnCarByCustomer: returnCarByCustomer,
            confirmPayout: confirmPayout,
            confirmRefund: confirmRefund,
          );
        },
      );
    }

    return RefreshIndicator(
      edgeOffset: 110.0,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {});
      },
      child: FutureBuilder(
        future: _fetchAllDetails(context, widget.carRentalId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Car Rental Details'),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            debugPrint('Error loading car rental details: ${snapshot.error}');
            return Scaffold(
              appBar: AppBar(
                title: const Text('Car Rental Details'),
              ),
              body: const Center(
                child: Text(
                  'Error loading car rental details',
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Car Rental Details'),
              ),
              body: const Center(
                child: Text(
                  'Car Rental details not found. please try again later',
                ),
              ),
            );
          } else {
            final data = snapshot.data as Map<String, dynamic>;
            final CarRental carRental = data['carRental'];
            final car = data['car'];
            final address = data['address'];
            final host = data['host'];
            final StripeCharge stripeCharge = data['stripeCharge'];

            final User? currentUser = data['currentUser'];
            final List<CarRentalStatus?> carRentalStatusHistory =
                data['carRentalStatusHistory'];
            final User customer = data['customer'];
            final UserRole currentUserRole = data['currentUserRole'];
            final StripeTransaction stripeTransaction =
                data['stripeTransaction'];
            final IssueReport? latestIssueReport = data['latestIssueReport'];

            final totalAmount = stripeTransaction.amount;
            double hostEarnings = totalAmount * 0.85;
            hostEarnings = double.parse(hostEarnings.toStringAsFixed(1));
            double stripeFees = stripeTransaction.fee;
            stripeFees = double.parse(stripeFees.toStringAsFixed(1));
            double platformNetProfit = totalAmount - hostEarnings - stripeFees;
            platformNetProfit =
                double.parse(platformNetProfit.toStringAsFixed(1));
            double hostPlatformFees = totalAmount - hostEarnings;
            hostPlatformFees =
                double.parse(hostPlatformFees.toStringAsFixed(1));

            final duration =
                carRental.endDate!.difference(carRental.startDate!);
            final days = duration.inDays;
            final hours = duration.inHours % 24;
            final durationText =
                '${days > 0 ? '$days days' : ''}${days > 0 && hours > 0 ? ' and ' : ''}${hours > 0 ? '$hours hours' : ''}';

            return Scaffold(
              appBar: AppBar(
                title: const Text('Car Rental Details'),
                actions: [
                  IconButton(
                    onPressed: () => showEditCarRentalBottomSheet(
                      context,
                      carRental,
                      carRentalStatusHistory,
                      car,
                      totalAmount,
                    ),
                    icon: const Icon(Icons.more_vert_rounded),
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 15.0),
                        child: ReferenceNumberRow(
                          referenceNumber: carRental.referenceNumber,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // consider adding info icon to explain statuses in a dialog
                                  const Text(
                                    'Status',
                                    style: TextStyle(
                                      fontSize: 22.0,
                                    ),
                                  ),
                                  const SizedBox(width: 50.0),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CarRentalStatusIndicator(
                                          carRentalStatus: carRental.status ??
                                              CarRentalStatus.rentedByCustomer,
                                          userRole: currentUser?.userRole ??
                                              UserRole.customer,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(thickness: 0.3),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Text(
                                          address.toString(),
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20.0),
                                  _buildIconTextRowWithDate(
                                    context,
                                    Icons.access_time,
                                    'Pick-Up Time',
                                    carRental.startDate ?? DateTime.now(),
                                  ),
                                  const SizedBox(height: 20.0),
                                  _buildIconTextRowWithDate(
                                    context,
                                    Icons.access_time,
                                    'Drop-Off Time',
                                    carRental.endDate ?? DateTime.now(),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(thickness: 0.3),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Duration',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  Text(
                                    durationText,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (currentUserRole == UserRole.primaryAdmin ||
                                currentUserRole == UserRole.secondaryAdmin)
                              buildAdminPricingDetails(
                                totalAmount,
                                hostEarnings,
                                stripeFees,
                                platformNetProfit,
                              ),
                            if (currentUserRole == UserRole.host)
                              buildHostPricingDetails(
                                totalAmount,
                                hostPlatformFees,
                                hostEarnings,
                              ),
                            if (currentUserRole == UserRole.customer)
                              buildCustomerPricingDetails(
                                totalAmount,
                              ),
                          ],
                        ),
                      ),
                      _buildSectionTitle('Car Details'),
                      GestureDetector(
                        onTap: () {
                          if (currentUserRole == UserRole.primaryAdmin ||
                              currentUserRole == UserRole.secondaryAdmin) {
                            animatedPushNavigation(
                              context: context,
                              screen: ManageCarScreen(carId: car.id ?? ''),
                            );
                          } else {
                            animatedPushNavigation(
                              context: context,
                              screen: PreviewCarDetails(carId: car.id ?? ''),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: CachedNetworkImage(
                                  imageUrl: car.imagesUrl!.first,
                                  width: 100.0,
                                  height: 100.0,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      const CustomProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Center(child: Icon(Icons.error)),
                                ),
                              ),
                              const SizedBox(width: 20.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${car.manufacturer ?? 'N/A'} ${car.model ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  _buildIconTextRow(
                                    context,
                                    Icons.color_lens,
                                    car.color ?? 'N/A',
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                    ),
                                    child: Icon(
                                      Icons.keyboard_arrow_right_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (currentUser?.userId != carRental.customerId ||
                          currentUserRole == UserRole.primaryAdmin ||
                          currentUserRole == UserRole.secondaryAdmin)
                        _buildSectionTitle('Customer Details'),
                      if (currentUser?.userId != carRental.customerId ||
                          currentUserRole == UserRole.primaryAdmin ||
                          currentUserRole == UserRole.secondaryAdmin)
                        ListTile(
                          onTap: (currentUserRole == UserRole.primaryAdmin ||
                                  currentUserRole == UserRole.secondaryAdmin)
                              ? () => animatedPushNavigation(
                                    context: context,
                                    screen: UserDetailsScreen(
                                        userId: customer.userId ?? ''),
                                  )
                              : null,
                          leading: ClipOval(
                            child: customer.userProfileUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: customer.userProfileUrl ?? '',
                                    width: 50.0,
                                    height: 50.0,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  )
                                : const Icon(Icons.person),
                          ),
                          title: Text(
                            '${customer.userFirstName ?? ''} ${customer.userLastName ?? ''}',
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            customer.userPhoneNumber ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.phone,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () =>
                                LaunchCoreServiceUtil.launchPhoneCall(
                              customer.userPhoneNumber ?? '',
                            ),
                          ),
                        ),
                      if (currentUser?.userId == carRental.customerId ||
                          currentUserRole == UserRole.primaryAdmin ||
                          currentUserRole == UserRole.secondaryAdmin)
                        _buildSectionTitle('Host Details'),
                      if (currentUser?.userId == carRental.customerId ||
                          currentUserRole == UserRole.primaryAdmin ||
                          currentUserRole == UserRole.secondaryAdmin)
                        ListTile(
                          onTap: (currentUserRole == UserRole.primaryAdmin ||
                                  currentUserRole == UserRole.secondaryAdmin)
                              ? () => animatedPushNavigation(
                                    context: context,
                                    screen: UserDetailsScreen(
                                        userId: host.userId ?? ''),
                                  )
                              : null,
                          leading: ClipOval(
                            child: host.userProfileUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: host.userProfileUrl ?? '',
                                    width: 50.0,
                                    height: 50.0,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  )
                                : const Icon(Icons.person),
                          ),
                          title: Text(
                            '${host.userFirstName ?? ''} ${host.userLastName ?? ''}',
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            host.userPhoneNumber ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.phone,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () =>
                                LaunchCoreServiceUtil.launchPhoneCall(
                              host.userPhoneNumber ?? '',
                            ),
                          ),
                        ),
                      if (currentUser?.userId == carRental.customerId)
                        _buildSectionTitle('Car Address'),
                      if (currentUser?.userId == carRental.customerId)
                        CarAddressImagePreview(
                          addressId: car.defaultAddressId,
                        ),
                      if (currentUserRole == UserRole.customer)
                        _buildSectionTitle('Payment Method'),
                      if (currentUserRole == UserRole.customer)
                        CarRentalPaymentCarTile(
                          stripeCharge: stripeCharge,
                        ),
                      // customer shouldn't see payout status, only customer, check which other statuses he shouldn't see
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: CarRentalLatestStatusHistoryRecord(
                          fetchStatusHistory: getMostRecentStatusHistory,
                          linkedObjectId: carRental.id ?? '',
                        ),
                      ),
                      if (latestIssueReport != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: CarRentalLatestIssueReport(
                            latestIssueReport: latestIssueReport,
                            carRentalId: carRental.id ?? '',
                          ),
                        ),
                      const Divider(thickness: 0.3),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: CreatedAtRow(
                          labelText: 'Created At',
                          createdAt: carRental.createdAt,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
