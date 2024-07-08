// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:prime/providers/customer_provider.dart';
import 'package:prime/providers/user_provider.dart';
import 'package:prime/services/firebase/firebase_auth_service.dart';
import 'package:prime/services/stripe/stripe_customer.dart';
import 'package:prime/services/stripe/stripe_payment_method_service.dart';
import 'package:prime/services/stripe/stripe_setup_intents.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';
import 'package:prime/widgets/no_data_found.dart';
import 'package:provider/provider.dart';
import 'package:prime/utils/snackbar.dart';

import '../../models/stripe_payment_method.dart';

class PaymentCardsTabBody extends StatefulWidget {
  const PaymentCardsTabBody({super.key});

  @override
  State<PaymentCardsTabBody> createState() => _PaymentCardsTabBodyState();
}

class _PaymentCardsTabBodyState extends State<PaymentCardsTabBody> {
  List<StripePaymentMethod> savedCards = [];
  bool isAddPaymentCarLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  setAddPaymentCardLoading(bool value) {
    setState(() {
      isAddPaymentCarLoading = value;
    });
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final userId = FirebaseAuthService().currentUser?.uid ?? '';
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );
      final stripePaymentMethodService = StripePaymentMethodService();

      final stripeCustomerId =
          await customerProvider.getStripeAccountId(userId);

      if (stripeCustomerId.isNotEmpty) {
        final paymentMethods =
            await stripePaymentMethodService.listCustomerPaymentMethods(
          stripeCustomerId,
        );

        setState(() {
          savedCards = paymentMethods;
        });
      }
    } catch (_) {
      if (mounted) {
        buildFailureSnackbar(
          context: context,
          message: 'Failed to load payment methods.',
        );
      }
    }
  }

  Future<void> _deletePaymentMethod(String paymentMethodId) async {
    try {
      final stripePaymentMethodService = StripePaymentMethodService();
      await stripePaymentMethodService.detachPaymentMethodFromCustomer(
        paymentMethodId,
      );
      setState(() {
        savedCards.removeWhere(
          (paymentMethod) => paymentMethod.paymentMethodId == paymentMethodId,
        );
      });
    } catch (_) {
      if (mounted) {
        buildFailureSnackbar(
          context: context,
          message: 'Failed to delete payment method.',
        );
      }
    }
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

  Future<void> _addPaymentCard(BuildContext context) async {
    try {
      setAddPaymentCardLoading(true);

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
      final paymentSetupService = StripeSetupIntents();
      final setupIntent = await paymentSetupService.createSetupIntent(
        stripeCustomerId,
      );

      final billingDetails = stripe.BillingDetails(
        name: customerName,
        email: customerEmail,
        phone: customerPhone,
        address: null,
      );

      // await Stripe.instance.initCustomerSheet(customerSheetInitParams: ,);
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'PRIME',
          customerId: setupIntent['customer'],
          customerEphemeralKeySecret: setupIntent['ephemeralKey'],
          setupIntentClientSecret: setupIntent['client_secret'],
          primaryButtonLabel: 'Add Card',
          removeSavedPaymentMethodMessage: 'Remove Card',
          billingDetails: billingDetails,
        ),
      );
      await stripe.Stripe.instance.presentPaymentSheet();
      setAddPaymentCardLoading(false);
      _loadPaymentMethods();
      if (mounted) {
        buildSuccessSnackbar(
          context: context,
          message: 'Payment card added successfully.',
        );
      }
    } catch (_) {
      setAddPaymentCardLoading(false);
      if (mounted) {
        buildFailureSnackbar(
          context: context,
          message: 'Failed to add payment card. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadPaymentMethods();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: savedCards.isEmpty
                  ? const NoDataFound(
                      title: 'No Payment Cards Found',
                      subTitle:
                          'Add your payment cards to pay when renting a car.',
                    )
                  : ListView.builder(
                      itemCount: savedCards.length,
                      itemBuilder: (context, index) {
                        final card = savedCards[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.credit_card_rounded),
                            title: Text(
                              '${card.cardBrand?.toUpperCase()} **** ${card.cardLast4}',
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'EXPIRY ${card.cardExpiryMonth}/${card.cardExpiryYear}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deletePaymentMethod(card.paymentMethodId!);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(
              height: 50,
              child: isAddPaymentCarLoading
                  ? const CustomProgressIndicator()
                  : FilledButton(
                      onPressed: () => _addPaymentCard(context),
                      child: const Text(
                        'Add Payment Card',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
