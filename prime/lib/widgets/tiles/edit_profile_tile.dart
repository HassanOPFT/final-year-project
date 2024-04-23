import 'package:flutter/material.dart';

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
      onTap: () {},
    );
  }
}