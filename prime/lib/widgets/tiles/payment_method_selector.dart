// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:prime/providers/customer_provider.dart';
import 'package:prime/providers/stripe_payment_method_provider.dart';
import 'package:prime/services/firebase/firebase_auth_service.dart';
import 'package:provider/provider.dart';

class PaymentMethodSelector extends StatefulWidget {
  const PaymentMethodSelector({super.key});

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final userId = FirebaseAuthService().currentUser?.uid ?? '';
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );
      final stripeCustomerId = await customerProvider.getStripeAccountId(
        userId,
      );

      final stripePaymentMethodProvider =
          Provider.of<StripePaymentMethodProvider>(
        context,
        listen: false,
      );

      await stripePaymentMethodProvider.loadPaymentMethods(stripeCustomerId);
    } catch (_) {
      // if (mounted) {
      //   buildFailureSnackbar(
      //     context: context,
      //     message: 'Failed to load payment methods.',
      //   );
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StripePaymentMethodProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.savedCards.length + 1,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: RadioListTile(
                    value: index,
                    groupValue: provider.selectedIndex,
                    onChanged: (value) {
                      provider.selectPaymentMethod(value!);
                    },
                    title: Row(
                      children: [
                        const Icon(Icons.credit_card, size: 20),
                        const SizedBox(width: 12.0),
                        if (index < provider.savedCards.length)
                          Text(
                            '${provider.savedCards[index].cardBrand?.toUpperCase()} **** ${provider.savedCards[index].cardLast4}',
                            style: const TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        if (index == provider.savedCards.length)
                          const Text('Pay with new card'),
                      ],
                    ),
                    subtitle: (index < provider.savedCards.length)
                        ? Text(
                            'EXPIRY ${provider.savedCards[index].cardExpiryMonth}/${provider.savedCards[index].cardExpiryYear}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          )
                        : null,
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                );
              },
            ),
            if (provider.isNewCardSelected)
              CheckboxListTile(
                title: const Text('Save card under my account'),
                value: provider.saveCard,
                onChanged: (value) {
                  provider.toggleSaveCard(value!);
                },
              ),
          ],
        );
      },
    );
  }
}
