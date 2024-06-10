// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Address;
import 'package:intl/intl.dart';
import 'package:prime/models/car.dart';
import 'package:prime/providers/customer_provider.dart';
import 'package:prime/providers/user_provider.dart';
import 'package:prime/services/firebase/firebase_auth_service.dart';
import 'package:prime/services/stripe/stripe_payment_intents.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/utils/snackbar.dart';
import 'package:prime/views/rentals/car_rental_confirmation_screen.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';
import '../../providers/car_provider.dart';
import '../../providers/car_rental_provider.dart';
import '../../services/stripe/stripe_customer.dart';

class ConfirmCarRentalScreen extends StatefulWidget {
  final String carId;
  final DateTime? pickUpDateTime;
  final DateTime? dropOffDateTime;

  const ConfirmCarRentalScreen({
    super.key,
    required this.carId,
    required this.pickUpDateTime,
    required this.dropOffDateTime,
  });

  @override
  State<ConfirmCarRentalScreen> createState() => _ConfirmCarRentalScreenState();
}

class _ConfirmCarRentalScreenState extends State<ConfirmCarRentalScreen> {
  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(context);
    int days = -1;
    int hours = -1;
    double totalForDays = -1;
    double totalForHours = -1;
    double totalPrice = -1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Car Rental'),
      ),
      body: StreamBuilder<CarStatus>(
        stream: carProvider.listenToCarStatus(widget.carId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomProgressIndicator();
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error occurred. Please try again later.'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('Car details is not available at the moment.'),
            );
          }
          // If the car status is not approved, pop the screen
          if (snapshot.data != CarStatus.approved) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.of(context).pop();
            });
          }
          return FutureBuilder<Car?>(
            future: carProvider.getCarById(widget.carId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CustomProgressIndicator();
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Error occurred. Please try again later.'),
                );
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
                  child: Text('Car details is not available at the moment.'),
                );
              }
              final car = snapshot.data!;

              // Calculate the total price
              final duration =
                  widget.dropOffDateTime!.difference(widget.pickUpDateTime!);

              days = duration.inDays;
              hours = duration.inHours % 24;
              totalForDays = days * (car.dayPrice ?? 0.0);
              totalForDays = double.parse(totalForDays.toStringAsFixed(1));
              totalForHours = hours * (car.hourPrice ?? 0.0);
              totalForHours = double.parse(totalForHours.toStringAsFixed(1));
              totalPrice = totalForDays + totalForHours;

              final durationText =
                  '${days > 0 ? '$days days' : ''}${days > 0 && hours > 0 ? ' and ' : ''}${hours > 0 ? '$hours hours' : ''}';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        child: CachedNetworkImage(
                                          imageUrl: car.imagesUrl!.first,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const CustomProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Center(
                                                  child: Icon(Icons.error)),
                                        ),
                                      ),
                                      const SizedBox(width: 20.0),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                          const SizedBox(height: 8.0),
                                          _buildIconTextRow(
                                            context,
                                            Icons.attach_money,
                                            totalPrice.toString(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            _buildSectionTitle('Pick-Up & Drop-Off'),
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
                                  FutureBuilder<Address?>(
                                    future:
                                        Provider.of<AddressProvider>(context)
                                            .getAddressById(
                                      car.defaultAddressId ?? '',
                                    ),
                                    builder: (context, snapshot) {
                                      String address = '';
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CustomProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        address = 'N/A';
                                      } else if (!snapshot.hasData ||
                                          snapshot.data == null) {
                                        address = 'N/A';
                                      }
                                      final defaultAddress = snapshot.data!;
                                      address = defaultAddress.toString();
                                      return _buildLocationIconTextRow(
                                        context,
                                        Icons.location_on,
                                        address,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20.0),
                                  _buildIconTextRowWithDate(
                                    context,
                                    Icons.access_time,
                                    'Pick-Up Time',
                                    widget.pickUpDateTime ?? DateTime.now(),
                                  ),
                                  const SizedBox(height: 20.0),
                                  _buildIconTextRowWithDate(
                                    context,
                                    Icons.access_time,
                                    'Drop-Off Time',
                                    widget.dropOffDateTime ?? DateTime.now(),
                                  ),
                                ],
                              ),
                            ),
                            _buildSectionTitle('Pricing'),
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
                                  _buildPricingRow(
                                    'Hourly Rate',
                                    '${car.hourPrice ?? 0.0} per hour',
                                  ),
                                  _buildPricingRow(
                                    'Daily Rate',
                                    '${car.dayPrice ?? 0.0} per day',
                                  ),
                                  _buildPricingRow(
                                    'Duration',
                                    durationText,
                                  ),
                                  const Divider(thickness: 0.3),
                                  _buildAmountDetails(
                                    'Total for ${hours.toString()} hours',
                                    'RM$totalForHours',
                                  ),
                                  _buildAmountDetails(
                                    'Total for ${days.toString()} days',
                                    'RM$totalForDays',
                                  ),
                                  const Divider(thickness: 0.3),
                                  _buildAmountDetails(
                                    'Total Rent',
                                    'RM$totalPrice',
                                    isTotal: true,
                                  ),
                                ],
                              ),
                            ),
                            // TODO: Implement payment method selection
                            // _buildSectionTitle('Payment Method'),
                            // const PaymentMethodSelector(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    ConfirmAndPayButton(
                      car: car,
                      totalPrice: totalPrice,
                      confirmAndPay: confirmAndPay,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
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

  Future<String> getOrCreateStripeCustomerId(
    String userId,
    String name,
    String email,
    String addressLine1,
    String addressLine2,
    String city,
    String state,
    String postalCode,
    String country,
    String phone,
  ) async {
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );
    final stripeCustomerService = StripeCustomer();

    String? existingCustomerId =
        await customerProvider.getStripeAccountId(userId);

    if (existingCustomerId.isNotEmpty) {
      return existingCustomerId;
    } else {
      // If the user doesn't have a customer ID, create a new Stripe customer
      final customerData = await stripeCustomerService.createCustomer(
        name,
        email,
        addressLine1,
        addressLine2,
        city,
        state,
        postalCode,
        country,
        phone,
      );

      final customerId = customerData['id'];
      await customerProvider.setStripeAccountId(
          userId: userId, stripeCustomerId: customerId);

      return customerId;
    }
  }

  Future<void> confirmAndPay({
    required double totalPrice,
    required String carName,
    required String carImage,
    required String carAddressId,
    required String carColor,
    required CarStatus carStatus,
  }) async {
    // check both dates
    if (widget.pickUpDateTime == null || widget.dropOffDateTime == null) {
      buildAlertSnackbar(
        context: context,
        message: 'Please select pick-up and drop-off dates.',
      );
      return;
    }

    try {
      final userId = FirebaseAuthService().currentUser?.uid ?? '';
      final user = await Provider.of<UserProvider>(
        context,
        listen: false,
      ).getUserDetails(userId);
      final customerName = '${user?.userFirstName} ${user?.userLastName}';
      final customerEmail = user?.userEmail ?? '';
      final customerPhone = user?.userPhoneNumber ?? '';
      final stripeCustomerId = await getOrCreateStripeCustomerId(
        userId,
        customerName,
        customerEmail,
        '',
        '',
        '',
        '',
        '',
        '',
        customerPhone,
      );
      int totalAmountInCents = (totalPrice * 100).toInt();

      final paymentIntentObject = StripePaymentIntents();
      final paymentIntent = await paymentIntentObject.createPaymentIntent(
        amount: totalAmountInCents.toString(),
        currency: 'MYR',
        customerId: stripeCustomerId,
      );

      final billingDetails = BillingDetails(
        name: customerName,
        email: customerEmail,
        phone: customerPhone,
        address: null,
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'PRIME',
          customerId: paymentIntent['customer'],
          customerEphemeralKeySecret: paymentIntent['ephemeralKey'],
          paymentIntentClientSecret: paymentIntent['client_secret'],
          primaryButtonLabel: 'Pay now',
          removeSavedPaymentMethodMessage: 'Remove Card',
          intentConfiguration: IntentConfiguration(
            mode: IntentMode(
              currencyCode: 'MYR',
              amount: totalAmountInCents,
              setupFutureUsage: IntentFutureUsage.OffSession,
              captureMethod: CaptureMethod.Automatic,
            ),
          ),
          billingDetails: billingDetails,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      final successfulPaymentIntent = await paymentIntentObject
          .getPaymentIntent(paymentIntentId: paymentIntent['id']);

      // get the charge ID from the payment intent
      final chargeId = successfulPaymentIntent['latest_charge'];

      final carRentalProvider = Provider.of<CarRentalProvider>(
        context,
        listen: false,
      );

      final carRentalId = await carRentalProvider.createCarRental(
        carId: widget.carId,
        customerId: userId,
        startDate: widget.pickUpDateTime!,
        endDate: widget.dropOffDateTime!,
        stripeChargeId: chargeId,
      );

      // update the car status
      final carProvider = Provider.of<CarProvider>(
        context,
        listen: false,
      );
      carProvider.updateCarStatus(
        carId: widget.carId,
        previousStatus: carStatus,
        newStatus: CarStatus.upcomingRental,
        modifiedById: userId,
      );

      final carAddress = await Provider.of<AddressProvider>(
        context,
        listen: false,
      ).getAddressById(carAddressId);

      animatedPushReplacementNavigation(
        context: context,
        screen: CarRentalConfirmationScreen(
          carName: carName,
          carImage: carImage,
          carColor: carColor,
          carAddress: carAddress.toString(),
          pickUpTime: widget.pickUpDateTime ?? DateTime.now(),
          dropOffTime: widget.dropOffDateTime ?? DateTime.now(),
          totalPrice: totalPrice.toString(),
          carRentalId: carRentalId,
        ),
      );

      if (mounted) {
        buildSuccessSnackbar(
          context: context,
          message: 'Payment successful. Thank you for renting with us!',
        );
      }
    } on Exception catch (e) {
      if (e is StripeException) {
        String message =
            'Error occurred while processing payment. Please try again.';
        switch (e.error.code) {
          case FailureCode.Failed:
            message = 'Payment failed. Please try again.';
            break;
          case FailureCode.Canceled:
            message = 'Payment canceled. Please try again.';
            break;
          case FailureCode.Timeout:
            message = 'Payment timed out. Please try again.';
            break;
          default:
            message =
                'Error occurred while processing payment. Please try again.';
            break;
        }
        buildFailureSnackbar(
          context: context,
          message: message,
        );
      } else {
        buildFailureSnackbar(
          context: context,
          message: 'Error occurred while processing payment. Please try again.',
        );
      }
    }
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

  Widget _buildLocationIconTextRow(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8.0),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16.0,
            ),
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

  Widget _buildPricingRow(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDetails(
    String title,
    String amount, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class ConfirmAndPayButton extends StatefulWidget {
  final Car car;
  final double totalPrice;
  final Future<void> Function({
    required String carAddressId,
    required String carColor,
    required String carImage,
    required String carName,
    required CarStatus carStatus,
    required double totalPrice,
  }) confirmAndPay;
  const ConfirmAndPayButton({
    super.key,
    required this.car,
    required this.totalPrice,
    required this.confirmAndPay,
  });

  @override
  State<ConfirmAndPayButton> createState() => _ConfirmAndPayButtonState();
}

class _ConfirmAndPayButtonState extends State<ConfirmAndPayButton> {
  @override
  Widget build(BuildContext context) {
    bool isButtonLoading = false;
    setIsButtonLoading(bool value) {
      setState(() {
        isButtonLoading = value;
      });
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: SizedBox(
        width: double.infinity,
        height: 50.0,
        child: isButtonLoading
            ? const CustomProgressIndicator()
            : FilledButton(
                onPressed: () {
                  widget.confirmAndPay(
                    totalPrice: widget.totalPrice,
                    carName: '${widget.car.manufacturer} ${widget.car.model}',
                    carImage: widget.car.imagesUrl!.first,
                    carAddressId: widget.car.defaultAddressId ?? '',
                    carColor: widget.car.color ?? 'N/A',
                    carStatus: widget.car.status ?? CarStatus.approved,
                  );
                },
                child: const Text(
                  'Confirm & Pay',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
      ),
    );
  }
}
