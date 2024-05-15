import 'package:flutter/material.dart';
import 'package:prime/utils/navigate_with_animation.dart';

import '../../views/profile/change_password_screen.dart';

class ChangePasswordTile extends StatelessWidget {
  const ChangePasswordTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.lock_rounded),
      title: const Text(
        'Change Password',
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
      trailing: const Icon(Icons.keyboard_arrow_right_rounded),
      onTap: () => animatedPushNavigation(
        context: context,
        screen: const ChangePasswordScreen(),
      ),
    );
  }
}
