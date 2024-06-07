import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Car Rental'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
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
                        child: Image.network(
                          'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGNhcnN8ZW58MHx8MHx8fDA%3D',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BMW M5 Series',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              Icon(
                                Icons.color_lens,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4.0),
                              const Text(
                                'Silver',
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4.0),
                              const Text(
                                'Bronx, New York, USA',
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4.0),
                              const Text(
                                '171,250',
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Pricing',
              style: TextStyle(
                fontSize: 22.0,
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildAmountDetails('Amount', '\$170,000'),
                  buildAmountDetails('Shipping', '\$250'),
                  buildAmountDetails('Tax', '\$1,000'),
                  const SizedBox(height: 10.0),
                  const Divider(thickness: 0.3),
                  buildAmountDetails('Total Rent', '\$171,250', isTotal: true),
                  // const SizedBox(height: 20.0),
                  // const Text(
                  //   'Pick-Up Location & Time',
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // const SizedBox(height: 8.0),
                  // Text(
                  //   '61480 Sun brook Park, PC 5679\n${widget.pickUpDateTime}',
                  //   style: const TextStyle(
                  //     fontSize: 16,
                  //     color: Colors.grey,
                  //   ),
                  // ),
                  // const SizedBox(height: 20.0),
                  // const Text(
                  //   'Drop-Off Location & Time',
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // const SizedBox(height: 8.0),
                  // Text(
                  //   '61480 Sun brook Park, PC 5679\n${widget.dropOffDateTime}',
                  //   style: const TextStyle(
                  //     fontSize: 16,
                  //     color: Colors.grey,
                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            // TODO: Add payment method selection from customer cards if available
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 22.0,
              ),
            ),
            const SizedBox(height: 20.0),
            const PaymentMethodSelector(),
            const SizedBox(height: 40.0),
            SizedBox(
              height: 50.0,
              child: FilledButton(
                onPressed: () {},
                child: const Text(
                  'Pay Now',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAmountDetails(String title, String amount,
      {bool isTotal = false}) {
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

class PaymentMethodSelector extends StatefulWidget {
  const PaymentMethodSelector({super.key});

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  int _selectedIndex = 0;
  bool _saveCard = true;

  List<String> savedCards = [
    // '**** **** **** 4679',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: savedCards.length + 1,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: RadioListTile(
                value: index,
                groupValue: _selectedIndex,
                onChanged: (value) {
                  setState(() {
                    _selectedIndex = value!;
                    if (index == savedCards.length) {
                      _saveCard = true;
                    }
                  });
                },
                title: Row(
                  children: [
                    const Icon(Icons.credit_card, size: 20),
                    const SizedBox(width: 12.0),
                    if (index < savedCards.length) Text(savedCards[index]),
                    if (index == savedCards.length)
                      const Text('Pay with new card'),
                  ],
                ),
                controlAffinity: ListTileControlAffinity.trailing,
              ),
            );
          },
        ),
        if (_selectedIndex == savedCards.length)
          CheckboxListTile(
            title: const Text('Save card under my account'),
            value: _saveCard,
            onChanged: (value) {
              setState(() {
                _saveCard = value!;
              });
            },
          ),
      ],
    );
  }
}
