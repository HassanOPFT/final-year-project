import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prime/models/status_history.dart';

import '../models/issue_report.dart';
import '../utils/generate_reference_number.dart';
import 'status_history_controller.dart';

class IssueReportController {
  static const String _issueReportCollectionName = 'IssueReport';
  static const String _referenceNumberFieldName = 'referenceNumber';
  static const String _carRentalIdFieldName = 'carRentalId';
  static const String _reporterIdFieldName = 'reporterId';
  static const String _reportSubjectFieldName = 'reportSubject';
  static const String _reportDescriptionFieldName = 'reportDescription';
  static const String _statusFieldName = 'status';
  static const String _createdAtFieldName = 'createdAt';

  final _issueReportCollection = FirebaseFirestore.instance.collection(
    _issueReportCollectionName,
  );
  final _statusHistoryController = StatusHistoryController();

  Future<void> createIssueReport({
    required String carRentalId,
    required String reporterId,
    required String reportSubject,
    required String reportDescription,
  }) async {
    if (carRentalId.isEmpty ||
        reporterId.isEmpty ||
        reportSubject.isEmpty ||
        reportDescription.isEmpty) {
      throw Exception(
        'Car Rental ID, Reporter ID, Report Subject, and Report Description cannot be empty',
      );
    }

    final issueReportReferenceNumber = generateReferenceNumber('IR');

    try {
      final newIssueReport = await _issueReportCollection.add({
        _carRentalIdFieldName: carRentalId,
        _reporterIdFieldName: reporterId,
        _reportSubjectFieldName: reportSubject,
        _reportDescriptionFieldName: reportDescription,
        _statusFieldName: IssueReportStatus.open.name,
        _referenceNumberFieldName: issueReportReferenceNumber,
        _createdAtFieldName: Timestamp.fromDate(DateTime.now()),
      });

      // Create StatusHistory Record
      await _statusHistoryController.createStatusHistory(
        StatusHistory(
          linkedObjectId: newIssueReport.id,
          linkedObjectType: 'IssueReport',
          linkedObjectSubtype: '',
          previousStatus: IssueReportStatus.open.getStatusString(),
          newStatus: IssueReportStatus.open.getStatusString(),
          statusDescription: '',
          modifiedById: reporterId,
        ),
      );

      // update the status to inProgress
      await _issueReportCollection.doc(newIssueReport.id).update({
        _statusFieldName: IssueReportStatus.inProgress.name,
      });

      // Create StatusHistory Record
      await _statusHistoryController.createStatusHistory(
        StatusHistory(
          linkedObjectId: newIssueReport.id,
          linkedObjectType: 'IssueReport',
          linkedObjectSubtype: '',
          previousStatus: IssueReportStatus.open.getStatusString(),
          newStatus: IssueReportStatus.inProgress.getStatusString(),
          statusDescription: '',
          modifiedById: reporterId,
        ),
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<IssueReport?> getLatestIssueReportByCarRentalId(
    String carRentalId,
  ) async {
    try {
      final issueReportsSnapshot = await _issueReportCollection
          .where(_carRentalIdFieldName, isEqualTo: carRentalId)
          .orderBy(_createdAtFieldName, descending: true)
          .limit(1)
          .get();

      if (issueReportsSnapshot.docs.isEmpty) {
        return null;
      }

      return IssueReport.fromMap(
        issueReportsSnapshot.docs.first.id,
        issueReportsSnapshot.docs.first.data(),
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<List<IssueReport>> getIssueReportsByCarRentalId(
    String carRentalId,
  ) async {
    try {
      final issueReportsSnapshot = await _issueReportCollection
          .where(_carRentalIdFieldName, isEqualTo: carRentalId)
          .get();

      if (issueReportsSnapshot.docs.isEmpty) {
        return [];
      }

      return issueReportsSnapshot.docs
          .map(
            (issueReport) => IssueReport.fromMap(
              issueReport.id,
              issueReport.data(),
            ),
          )
          .toList();
    } catch (_) {
      rethrow;
    }
  }

  Future<IssueReport?> getIssueReportById(String issueReportId) async {
    try {
      final issueReportSnapshot = await _issueReportCollection
          .doc(
            issueReportId,
          )
          .get();

      if (!issueReportSnapshot.exists || issueReportSnapshot.data() == null) {
        return null;
      }

      return IssueReport.fromMap(
        issueReportSnapshot.id,
        issueReportSnapshot.data()!,
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<List<IssueReport>> getAllIssueReports() async {
    try {
      final issueReportsSnapshot = await _issueReportCollection
          .orderBy(_createdAtFieldName, descending: true)
          .get();

      if (issueReportsSnapshot.docs.isEmpty) {
        return [];
      }

      return issueReportsSnapshot.docs
          .map(
            (issueReport) => IssueReport.fromMap(
              issueReport.id,
              issueReport.data(),
            ),
          )
          .toList();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateIssueReportStatus({
    required String issueReportId,
    required IssueReportStatus previousStatus,
    required IssueReportStatus newStatus,
    String? statusDescription = '',
    required String modifiedById,
  }) async {
    if (issueReportId.isEmpty || modifiedById.isEmpty) {
      throw Exception(
        'Issue Report ID, and Modified By ID cannot be empty',
      );
    }
    try {
      await _issueReportCollection.doc(issueReportId).update({
        _statusFieldName: newStatus.name,
      });

      // Create StatusHistory Record
      await _statusHistoryController.createStatusHistory(
        StatusHistory(
          linkedObjectId: issueReportId,
          linkedObjectType: 'IssueReport',
          linkedObjectSubtype: '',
          previousStatus: previousStatus.getStatusString(),
          newStatus: newStatus.getStatusString(),
          statusDescription: statusDescription,
          modifiedById: modifiedById,
        ),
      );
    } catch (_) {
      rethrow;
    }
  }
}
