import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RentalAgreement extends StatelessWidget {
  const RentalAgreement({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'By confirming this rental, you agree to the ',
        children: [
          TextSpan(
            text: 'rental agreement',
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 16.0,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                _showRentalTermsDialog(context);
              },
          ),
          const TextSpan(
            text: '.',
          ),
        ],
      ),
    );
  }

  void _showRentalTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Rental Agreement',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Once payment is made, cancellations by the customer are non-refundable. If the host cancels, the customer will receive a full refund. The car must be returned in the same condition as it was at pickup. The customer must pick up and return the car to the specified location in the app, which must be the same for both pickup and return. The host\'s contact information will be available once the rental is confirmed. By confirming this rental, you agree to these terms',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
