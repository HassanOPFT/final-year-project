import 'package:flutter/material.dart';

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
