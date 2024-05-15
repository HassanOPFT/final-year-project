import 'package:flutter/material.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/views/profile/edit_profile_screen.dart';

class EditProfileTile extends StatelessWidget {
  const EditProfileTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.person_rounded),
      title: const Text(
        'Edit Profile',
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
      trailing: const Icon(Icons.keyboard_arrow_right_rounded),
      onTap: () => animatedPushNavigation(
        context: context,
        screen: const EditProfileScreen(),
      ),
    );
  }
}
