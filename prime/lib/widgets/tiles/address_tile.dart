import 'package:flutter/material.dart';
import 'package:prime/utils/navigate_with_animation.dart';

import '../../views/profile/address_screen.dart';

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
      onTap: () => animatedPushNavigation(
        context: context,
        screen: const AddressScreen(),
      ),
    );
  }
}
