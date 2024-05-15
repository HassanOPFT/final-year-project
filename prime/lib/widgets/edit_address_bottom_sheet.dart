import 'package:flutter/material.dart';

class EditAddressBottomSheet extends StatelessWidget {
  final Function setAddressAsDefault;
  final Function updateAddress;
  final Function deleteAddress;
  final bool isDefault;

  const EditAddressBottomSheet({
    super.key,
    required this.setAddressAsDefault,
    required this.updateAddress,
    required this.deleteAddress,
    required this.isDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Edit Address',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5.0),
          const Divider(),
          const SizedBox(height: 15.0),
          if (!isDefault)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                setAddressAsDefault();
              },
              icon: const Icon(Icons.star_rounded),
              label: const Text(
                'Set as Default',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              updateAddress();
            },
            icon: const Icon(Icons.edit),
            label: const Text(
              'Update Address',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              deleteAddress();
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
            ),
            label: const Text(
              'Delete Address',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
