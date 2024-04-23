import 'package:flutter/material.dart';

class NotificationsSwitch extends StatefulWidget {
  const NotificationsSwitch({super.key});

  @override
  State<NotificationsSwitch> createState() => _NotificationsSwitchState();
}

class _NotificationsSwitchState extends State<NotificationsSwitch> {
  var notificationsEnabled = true;
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text(
        'Notifications',
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
      value: notificationsEnabled,
      selected: notificationsEnabled,
      onChanged: (newValue) => setState(() {
        notificationsEnabled = newValue;
      }),
      secondary: const Icon(Icons.notifications_rounded),
    );
  }
}
