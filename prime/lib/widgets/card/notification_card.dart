import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/models/notification.dart' as notification_model;

class NotificationCard extends StatelessWidget {
  final notification_model.Notification notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: notification.isRead ?? false
            ? null
            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      child: ListTile(
        leading: Icon(
          notification.isRead ?? false
              ? Icons.notifications_none_rounded
              : Icons.notifications_active_rounded,
        ),
        title: SelectableText(
          notification.title ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              notification.body ?? '',
              style: const TextStyle(
                fontSize: 12.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              notification.createdAt != null
                  ? DateFormat.yMMMd().add_jm().format(notification.createdAt!)
                  : '',
              style: TextStyle(
                color: Theme.of(context).dividerColor,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
