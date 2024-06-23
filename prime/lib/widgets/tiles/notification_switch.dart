// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firebase/firebase_auth_service.dart';
import '../../utils/snackbar.dart';

class NotificationsSwitch extends StatefulWidget {
  const NotificationsSwitch({super.key});

  @override
  State<NotificationsSwitch> createState() => _NotificationsSwitchState();
}

class _NotificationsSwitchState extends State<NotificationsSwitch> {
  var notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadInitialNotificationSetting();
  }

  void _loadInitialNotificationSetting() async {
    final userId = FirebaseAuthService().currentUser?.uid;
    if (userId != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = await userProvider.getUserDetails(userId);
      if (user != null && user.notificationsEnabled != null) {
        setState(() {
          notificationsEnabled = user.notificationsEnabled!;
        });
      }
    }
  }

  void _updateNotificationsSetting(bool newValue) async {
    final userId = FirebaseAuthService().currentUser?.uid;
    if (userId != null) {
      try {
        await Provider.of<UserProvider>(context, listen: false)
            .updateNotificationsEnabled(
          userId: userId,
          notificationsEnabled: newValue,
        );
        setState(() {
          notificationsEnabled = newValue;
        });
      } catch (_) {
        buildFailureSnackbar(
          context: context,
          message: 'Failed to update notification',
        );
      }
    }
  }

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
      onChanged: (newValue) => _updateNotificationsSetting(newValue),
      secondary: const Icon(Icons.notifications_rounded),
    );
  }
}
