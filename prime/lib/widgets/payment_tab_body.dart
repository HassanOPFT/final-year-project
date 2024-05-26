import 'package:flutter/material.dart';
import 'package:prime/widgets/no_data_found.dart';

class PaymentCardsTabBody extends StatelessWidget {
  const PaymentCardsTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Flexible(
            flex: 6,
            child: NoDataFound(
              title: 'No Payment Cards Found',
              subTitle: 'Add your payment cards to pay when renting a car.',
            ),
          ),
          Flexible(
            flex: 1,
            child: SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: () {},
                child: const Text(
                  'Add Payment Card',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
