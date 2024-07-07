import 'package:flutter/material.dart';
import 'package:prime/widgets/no_data_found.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/card/notification_card.dart';

class NotificationScreen extends StatefulWidget {
  final String userId;
  const NotificationScreen({super.key, required this.userId});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    Provider.of<NotificationProvider>(context);
    return RefreshIndicator(
      edgeOffset: 110.0,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {});
      },
      child: FutureBuilder(
        future: Provider.of<NotificationProvider>(
          context,
          listen: false,
        ).getNotificationsByUserId(widget.userId),
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
                padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
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
      ),
    );
  }
}
