import 'package:flutter/material.dart';

class HelpCenterTile extends StatelessWidget {
  const HelpCenterTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.help_rounded),
      title: const Text(
        'Help Center',
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
      trailing: const Icon(Icons.keyboard_arrow_right_rounded),
      onTap: () {},
    );
  }
}
