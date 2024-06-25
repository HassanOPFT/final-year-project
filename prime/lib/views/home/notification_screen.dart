import 'package:flutter/material.dart';
import 'package:prime/widgets/no_data_found.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/card/notification_card.dart';

class NotificationScreen extends StatelessWidget {
  final String userId;
  const NotificationScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    Provider.of<NotificationProvider>(context);
    return FutureBuilder(
      future: Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).getNotificationsByUserId(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Notifications'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Notifications'),
            ),
            body: const Center(child: Text('Error loading notifications')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Notifications'),
            ),
            body: const NoDataFound(
              title: 'No Notifications Found',
              subTitle: 'You\'re all caught up!',
            ),
          );
        } else {
          final notifications = snapshot.data!;
          final unreadNotificationIds = notifications
              .where((notification) => !(notification.isRead ?? true))
              .map((notification) => notification.id)
              .whereType<String>()
              .toList();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Notifications'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.checklist_rounded),
                  onPressed: unreadNotificationIds.isNotEmpty
                      ? () async {
                          await Provider.of<NotificationProvider>(
                            context,
                            listen: false,
                          ).markAllNotificationsAsRead(unreadNotificationIds);
                        }
                      : null,
                ),
              ],
            ),
            body: ListView.builder(
              itemCount: notifications.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationCard(
                  notification: notification,
                );
              },
            ),
          );
        }
      },
    );
  }
}
