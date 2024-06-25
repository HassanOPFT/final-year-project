import 'package:flutter/foundation.dart';
import 'package:prime/controllers/notification_controller.dart';
import 'package:prime/models/notification.dart';

class NotificationProvider with ChangeNotifier {
  final _notificationController = NotificationController();

  Future<bool> hasUnreadNotification(String userId) async {
    try {
      final hasUnread =
          await _notificationController.hasUnreadNotification(userId);
      return hasUnread;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Notification>> getNotificationsByUserId(String userId) async {
    try {
      final notifications =
          await _notificationController.getNotificationsByUserId(userId);
      return notifications;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationController.markNotificationAsRead(
        notificationId,
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllNotificationsAsRead(List<String> notificationIds) async {
    try {
      await _notificationController.markAllNotificationsAsRead(
        notificationIds,
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
