import 'package:flutter/material.dart';

class AddressTile extends StatelessWidget {
  const AddressTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.location_on_rounded),
      title: const Text(
        'Address',
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
      trailing: const Icon(Icons.keyboard_arrow_right_rounded),
      onTap: () {},
    );
  }
}
