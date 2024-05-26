import 'package:flutter/material.dart';

import '../controllers/status_history_controller.dart';
import '../models/status_history.dart';

class StatusHistoryProvider extends ChangeNotifier {
  final _statusHistoryController = StatusHistoryController();

  Future<void> createStatusHistory(StatusHistory statusHistory) async {
    try {
      await _statusHistoryController.createStatusHistory(statusHistory);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<StatusHistory?> getMostRecentStatusHistory(
    String linkedObjectId,
  ) async {
    try {
      final statusHistory = await _statusHistoryController
          .getMostRecentStatusHistory(linkedObjectId);
      return statusHistory;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StatusHistory>> getStatusHistoryList(
      String linkedObjectId) async {
    try {
      final statusHistoryList =
          await _statusHistoryController.getStatusHistoryList(linkedObjectId);
      return statusHistoryList;
    } catch (e) {
      rethrow;
    }
  }

  void notify() {
    notifyListeners();
  }
}
