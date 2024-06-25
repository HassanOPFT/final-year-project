import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification.dart';

class NotificationController {
  static const String _notificationCollectionName = 'Notification';
  static const String _idFieldName = 'id';
  static const String _userIdFieldName = 'userId';
  static const String _titleFieldName = 'title';
  static const String _bodyFieldName = 'body';
  static const String _linkedObjectIdFieldName = 'linkedObjectId';
  static const String _linkedObjectTypeFieldName = 'linkedObjectType';
  static const String _isReadFieldName = 'isRead';
  static const String _isDeliveredFieldName = 'isDelivered';
  static const String _createdAtFieldName = 'createdAt';

  final _notificationCollection =
      FirebaseFirestore.instance.collection(_notificationCollectionName);

  Future<bool> hasUnreadNotification(String userId) async {
    try {
      final notificationSnapshot = await _notificationCollection
          .where(_userIdFieldName, isEqualTo: userId)
          .where(_isReadFieldName, isEqualTo: false)
          .get();

      return notificationSnapshot.docs.isNotEmpty;
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<List<Notification>> getNotificationsByUserId(String userId) async {
    try {
      final notificationSnapshot = await _notificationCollection
          .where(_userIdFieldName, isEqualTo: userId)
          .orderBy(_createdAtFieldName, descending: true)
          .get();

      if (notificationSnapshot.docs.isEmpty) {
        return [];
      }

      return notificationSnapshot.docs
          .map(
            (notification) => Notification.fromMap(
              notification.id,
              notification.data(),
            ),
          )
          .toList();
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<void> markNotificationAsRead(
    String notificationId,
  ) async {
    try {
      await _notificationCollection.doc(notificationId).update({
        _isReadFieldName: true,
      });
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<void> markAllNotificationsAsRead(
    List<String> notificationIds,
  ) async {
    final WriteBatch batch = FirebaseFirestore.instance.batch();
    try {
      for (String id in notificationIds) {
        batch.update(_notificationCollection.doc(id), {
          _isReadFieldName: true,
        });
      }
      await batch.commit();
    } on Exception catch (_) {
      rethrow;
    }
  }
}
