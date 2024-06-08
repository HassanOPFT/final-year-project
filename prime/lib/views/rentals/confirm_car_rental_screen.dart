// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Address;
import 'package:intl/intl.dart';
import 'package:prime/models/car.dart';
import 'package:prime/providers/customer_provider.dart';
import 'package:prime/providers/theme_provider.dart';
import 'package:prime/providers/user_provider.dart';
import 'package:prime/services/firebase/firebase_auth_service.dart';
import 'package:prime/services/stripe/stripe_payment_intents.dart';
import 'package:prime/utils/snackbar.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';
import '../../providers/car_provider.dart';
import '../../services/stripe/stripe_customer.dart';
import '../../widgets/tiles/payment_method_selector.dart';

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
            builder: (BuildContext context, AsyncSnapshot<Car?> snapshot) {
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
              totalForHours = hours * (car.hourPrice ?? 0.0);
              totalPrice = totalForDays + totalForHours;

              final durationText =
                  '${days > 0 ? '$days days' : ''}${days > 0 && hours > 0 ? ' and ' : ''}${hours > 0 ? '$hours hours' : ''}';

              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildCarDetailsCard(
                              context,
                              car.imagesUrl!.first,
                              car.manufacturer ?? 'N/A',
                              car.model ?? 'N/A',
                              car.color ?? 'N/A',
                              totalPrice.toString(),
                            ),
                            _buildSectionTitle('Pick-Up & Drop-Off'),
                            _buildPickUpDropOffCard(
                                context, car.defaultAddressId ?? ''),
                            _buildSectionTitle('Pricing'),
                            _buildPricingCard(
                              hours.toString(),
                              car.hourPrice ?? 0.0,
                              days.toString(),
                              car.dayPrice ?? 0.0,
                              durationText,
                              totalForDays,
                              totalForHours,
                              totalPrice,
                            ),
                            _buildSectionTitle('Payment Method'),
                            const PaymentMethodSelector(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    _buildConfirmAndPayButton(totalPrice: totalPrice),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCarDetailsCard(
    BuildContext context,
    String carImage,
    String carManufacturer,
    String carModel,
    String carColor,
    String rentTotal,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: CachedNetworkImage(
                  imageUrl: carImage,
                  width: 100,
                  height: 100,
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
                    '$carManufacturer $carModel',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  _buildIconTextRow(
                    context,
                    Icons.color_lens,
                    carColor,
                  ),
                  const SizedBox(height: 8.0),
                  _buildIconTextRow(
                    context,
                    Icons.attach_money,
                    rentTotal,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickUpDropOffCard(
      BuildContext context, String carDefaultAddressId) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<Address?>(
            future: Provider.of<AddressProvider>(context)
                .getAddressById(carDefaultAddressId),
            builder: (context, snapshot) {
              String address = '';
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CustomProgressIndicator();
              } else if (snapshot.hasError) {
                address = 'N/A';
              } else if (!snapshot.hasData || snapshot.data == null) {
                address = 'N/A';
              }
              final defaultAddress = snapshot.data!;
              // address =
              //     '${defaultAddress.street}, ${defaultAddress.city}, ${defaultAddress.state}';
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
    );
  }

  Widget _buildPricingCard(
    String hours,
    double hourPrice,
    String days,
    double dayPrice,
    String durationText,
    double daysTotalPrice,
    double hoursTotalPrice,
    double totalPrice,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPricingRow('Hourly Rate', '$hourPrice per hour'),
          _buildPricingRow('Daily Rate', '$dayPrice per day'),
          _buildPricingRow('Duration', durationText),
          const Divider(thickness: 0.3),
          _buildAmountDetails('Total for $hours hours', 'RM$hoursTotalPrice'),
          _buildAmountDetails('Total for $days days', 'RM$daysTotalPrice'),
          const Divider(thickness: 0.3),
          _buildAmountDetails('Total Rent', 'RM$totalPrice', isTotal: true),
        ],
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

  Future<void> _confirmAndPay({required double totalPrice}) async {
    debugPrint('#' * 25);
    debugPrint('Confirm and Pay');
    debugPrint('#' * 25);
    // TODO: Stripe accepts int only, see how to handle this
    try {
      // get the current user id from firebase auth service
      final userId = FirebaseAuthService().currentUser?.uid ?? '';
      // get user details from user provider
      final user = await Provider.of<UserProvider>(
        context,
        listen: false,
      ).getUserDetails(userId);
      final customerName = '${user?.userFirstName} ${user?.userLastName}';
      final customerEmail = user?.userEmail ?? '';
      final customerPhone = user?.userPhoneNumber ?? '';
      // create a method to check if current user has a stripe customer id, if not create one and then return the customer id
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

      final paymentIntent = await StripePaymentIntents().createPaymentIntent(
        amount: totalAmountInCents.toString(),
        currency: 'MYR',
        customerId: stripeCustomerId,
      );
      print('##############################');
      print('Payment Intent: $paymentIntent');
      print('##############################');

      final billingDetails = BillingDetails(
        name: customerName,
        email: customerEmail,
        phone: customerPhone,
        address: null,
      );

      print('#' * 30);
      print('Payment Intent Customer: ${paymentIntent['customer']}');
      print('Payment Intent Ephemeral Key: ${paymentIntent['ephemeralKey']}');
      print('Payment Intent Client Secret: ${paymentIntent['client_secret']}');
      print('#' * 30);

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
          style: ThemeMode.dark,
          billingDetails: billingDetails,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      if (mounted) {
        buildSuccessSnackbar(
          context: context,
          message: 'Payment successful. Thank you for renting with us!',
        );
      }
    } on Exception catch (e) {
      if (e is StripeException) {
        // print e
        // filter the error code and display the appropriate message based on this enum FailureCode { Failed, Canceled, Timeout }
        // create a switch for the FailureCode enum
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
        debugPrint('Error from Stripe: ${e.error.code}');
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

  Widget _buildConfirmAndPayButton({required double totalPrice}) {
    return SizedBox(
      width: double.infinity,
      height: 50.0,
      child: FilledButton(
        onPressed: () => _confirmAndPay(totalPrice: totalPrice),
        child: const Text(
          'Confirm & Pay',
          style: TextStyle(
            fontSize: 20.0,
          ),
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
            fontSize: 18.0,
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
              fontSize: 18.0,
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
            fontSize: 18.0,
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
              fontSize: 18.0,
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
              fontSize: 18.0,
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
