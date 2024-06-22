// create the IssueReportProvider class
import 'package:flutter/material.dart';

import '../controllers/issue_report_controller.dart';
import '../models/issue_report.dart';

class IssueReportProvider with ChangeNotifier {
  final _issueReportController = IssueReportController();

  Future<void> createIssueReport({
    required String carRentalId,
    required String reporterId,
    required String reportSubject,
    required String reportDescription,
  }) async {
    try {
      await _issueReportController.createIssueReport(
        carRentalId: carRentalId,
        reporterId: reporterId,
        reportSubject: reportSubject,
        reportDescription: reportDescription,
      );
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<IssueReport?> getLatestIssueReportByCarRentalId(
    String carRentalId,
  ) async {
    try {
      final issueReport =
          await _issueReportController.getLatestIssueReportByCarRentalId(
        carRentalId,
      );
      return issueReport;
    } catch (_) {
      rethrow;
    }
  }

  Future<List<IssueReport>> getIssueReportsByCarRentalId(
    String carRentalId,
  ) async {
    try {
      final issueReports =
          await _issueReportController.getIssueReportsByCarRentalId(
        carRentalId,
      );
      return issueReports;
    } catch (_) {
      rethrow;
    }
  }

  Future<IssueReport?> getIssueReportById(String issueReportId) async {
    try {
      final issueReport = await _issueReportController.getIssueReportById(
        issueReportId,
      );
      return issueReport;
    } catch (_) {
      rethrow;
    }
  }

  Future<List<IssueReport>> getAllIssueReports() async {
    try {
      final issueReports = await _issueReportController.getAllIssueReports();
      return issueReports;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateIssueReportStatus({
    required String issueReportId,
    required IssueReportStatus previousStatus,
    required IssueReportStatus newStatus,
    String? statusDescription,
    required String modifiedById,
  }) async {
    try {
      await _issueReportController.updateIssueReportStatus(
        issueReportId: issueReportId,
        previousStatus: previousStatus,
        newStatus: newStatus,
        statusDescription: statusDescription,
        modifiedById: modifiedById,
      );
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }
}
