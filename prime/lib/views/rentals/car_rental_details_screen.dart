// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/models/stripe_charge.dart';
import 'package:prime/models/stripe_transaction.dart';
import 'package:prime/services/firebase/firebase_auth_service.dart';
import 'package:prime/services/stripe/stripe_transaction_service.dart';
import 'package:prime/utils/launch_core_service_util.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/views/cars/manage_car_screen.dart';
import 'package:prime/views/rentals/preview_car_details.dart';
import 'package:prime/widgets/car_rental_latest_status_history_record.dart';
import 'package:prime/widgets/car_rental_status_indicator.dart';
import 'package:prime/widgets/created_at_row.dart';
import 'package:prime/widgets/reference_number_row.dart';
import 'package:provider/provider.dart';

import '../../models/address.dart';
import '../../models/car.dart';
import '../../models/car_rental.dart';
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

// TODO: Implement the extension rental if found
//TODO: Implement the issues reported details if found for this rental

class CarRentalDetailsScreen extends StatelessWidget {
  final String carRentalId;
  const CarRentalDetailsScreen({
    super.key,
    required this.carRentalId,
  });

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
      car!,
      carRental!,
      context,
    );

    final stripeTransaction = await _getStripeTransactionDetails(
      stripeCharge.balanceTransactionId ?? '',
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
    };
  }

  Future<CarRental?> _fetchCarRental(
    BuildContext context,
    String carRentalId,
  ) async {
    final carRentalProvider = Provider.of<CarRentalProvider>(
      context,
      listen: false,
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

  Future<void> pickUpByCustomer(CarRental carRental) async {}
  Future<void> confirmPickUpByHost(CarRental carRental) async {}
  Future<void> cancelCarRental(CarRental carRental) async {}
  Future<void> reportIssue(CarRental carRental) async {}
  Future<void> extendRental(CarRental carRental) async {}
  Future<void> confirmReturnByHost(CarRental carRental) async {}
  Future<void> returnCarByCustomer(CarRental carRental) async {}
  Future<void> confirmPayout(CarRental carRental) async {}
  Future<void> confirmRefund(CarRental carRental) async {}

  Future<void> showEditCarRentalBottomSheet(
    BuildContext context,
    CarRental carRental,
    List<CarRentalStatus?> carRentalStatusHistory,
    Car car,
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
      car,
      carRental,
      context,
    );

    // final userProvider = Provider.of<UserProvider>(context, listen: false);
    // final userRole = userProvider.getUserRole(currentUserId);

    // Check if the current user is allowed to modify the car rental based on its status
    // if (carRental.status == CarRentalStatus.adminConfirmedPayment && !isAdmin) {
    //   buildAlertSnackbar(
    //     context: context,
    //     message: 'Modification is not allowed for completed rentals.',
    //   );
    //   return;
    // }

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return EditCarRentalBottomSheet(
          userRole: currentUserRole!,
          carRental: carRental,
          carRentalStatusHistory: carRentalStatusHistory,
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

  Future<UserRole> getCurrentUserRole(
    String currentUserId,
    Car car,
    CarRental carRental,
    BuildContext context,
  ) async {
    UserRole? currentUserRole;
    if (currentUserId == car.hostId) {
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
    Future<StatusHistory?> getMostRecentStatusHistory(
        String? carRentalId) async {
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

    return FutureBuilder(
      future: _fetchAllDetails(context, carRentalId),
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
          debugPrint(
              'Error loading car rental details: ${snapshot.stackTrace}');
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
          final StripeTransaction stripeTransaction = data['stripeTransaction'];

          final totalAmount = stripeTransaction.amount;
          final hostEarnings = totalAmount * 0.85;
          final stripeFees = stripeTransaction.fee;
          final platformNetProfit = totalAmount - hostEarnings - stripeFees;
          final hostPlatformFees = totalAmount - hostEarnings;

          final duration = carRental.endDate!.difference(carRental.startDate!);
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
                      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 15.0),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 22.0,
                                  ),
                                ),
                                CarRentalStatusIndicator(
                                  carRentalStatus: carRental.status ??
                                      CarRentalStatus.rentedByCustomer,
                                  userRole: currentUser?.userRole ??
                                      UserRole.customer,
                                ),
                              ],
                            ),
                          ),
                          const Divider(thickness: 0.3),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      CarAddressImagePreview(addressId: car.defaultAddressId),
                    _buildSectionTitle('Payment Method'),
                    CarRentalPaymentCarTile(
                      stripeCharge: stripeCharge,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: CarRentalLatestStatusHistoryRecord(
                        fetchStatusHistory: getMostRecentStatusHistory,
                        linkedObjectId: carRental.id ?? '',
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
    );
  }
}
