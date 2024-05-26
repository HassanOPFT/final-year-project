import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/status_history.dart';

class StatusHistoryController {
  static const String _statusHistoryCollectionName = 'StatusHistory';
  static const String _linkedObjectIdFieldName = 'linkedObjectId';
  static const String _linkedObjectTypeFieldName = 'linkedObjectType';
  static const String _linkedObjectSubtypeFieldName = 'linkedObjectSubtype';
  static const String _previousStatusFieldName = 'previousStatus';
  static const String _newStatusFieldName = 'newStatus';
  static const String _statusDescriptionFieldName = 'statusDescription';
  static const String _modifiedByIdFieldName = 'modifiedById';
  static const String _createdAtFieldName = 'createdAt';

  final _collection =
      FirebaseFirestore.instance.collection(_statusHistoryCollectionName);

  Future<void> createStatusHistory(StatusHistory statusHistory) async {
    try {
      await _collection.add({
        _linkedObjectIdFieldName: statusHistory.linkedObjectId,
        _linkedObjectTypeFieldName: statusHistory.linkedObjectType,
        _linkedObjectSubtypeFieldName: statusHistory.linkedObjectSubtype,
        _previousStatusFieldName: statusHistory.previousStatus,
        _newStatusFieldName: statusHistory.newStatus,
        _statusDescriptionFieldName: statusHistory.statusDescription,
        _modifiedByIdFieldName: statusHistory.modifiedById,
        _createdAtFieldName: Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<StatusHistory?> getMostRecentStatusHistory(
    String linkedObjectId,
  ) async {
    try {
      QuerySnapshot snapshot = await _collection
          .where(_linkedObjectIdFieldName, isEqualTo: linkedObjectId)
          .orderBy(_createdAtFieldName, descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = snapshot.docs.first;
        return StatusHistory(
          id: doc.id,
          linkedObjectId: doc[_linkedObjectIdFieldName],
          linkedObjectType: doc[_linkedObjectTypeFieldName],
          linkedObjectSubtype: doc[_linkedObjectSubtypeFieldName],
          previousStatus: doc[_previousStatusFieldName],
          newStatus: doc[_newStatusFieldName],
          statusDescription: doc[_statusDescriptionFieldName],
          modifiedById: doc[_modifiedByIdFieldName],
          createdAt: (doc[_createdAtFieldName] as Timestamp).toDate(),
        );
      }
      return null;
    } catch (_) {
      rethrow;
    }
  }

  Future<List<StatusHistory>> getStatusHistoryList(
    String linkedObjectId,
  ) async {
    try {
      QuerySnapshot snapshot = await _collection
          .where(_linkedObjectIdFieldName, isEqualTo: linkedObjectId)
          .orderBy(_createdAtFieldName, descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return StatusHistory(
          id: doc.id,
          linkedObjectId: doc[_linkedObjectIdFieldName],
          linkedObjectType: doc[_linkedObjectTypeFieldName],
          linkedObjectSubtype: doc[_linkedObjectSubtypeFieldName],
          previousStatus: doc[_previousStatusFieldName],
          newStatus: doc[_newStatusFieldName],
          statusDescription: doc[_statusDescriptionFieldName],
          modifiedById: doc[_modifiedByIdFieldName],
          createdAt: (doc[_createdAtFieldName] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
