import 'package:flutter/foundation.dart';
import '../models/issue_report.dart';
import '../models/user.dart';
import '../models/car_rental.dart';

class SearchIssueReportsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _issueReportsList = [];
  List<Map<String, dynamic>> _filteredIssueReports = [];
  bool _isSearchFilterActive = false;

  List<Map<String, dynamic>> get issueReportsList => _issueReportsList;
  List<Map<String, dynamic>> get filteredIssueReports => _filteredIssueReports;
  bool get isSearchFilterActive => _isSearchFilterActive;

  void setIssueReportsList(List<Map<String, dynamic>> issueReports) {
    _issueReportsList = issueReports;
    notifyListeners();
  }

  void filterIssueReports(String query) {
    if (query.isEmpty) {
      _isSearchFilterActive = false;
      _filteredIssueReports = [];
    } else {
      _isSearchFilterActive = true;
      _filteredIssueReports = _issueReportsList.where((issueReport) {
        final IssueReport report = issueReport['report'];
        final CarRental rental = issueReport['rental'];
        final User user = issueReport['user'];
        final lowerQuery = query.toLowerCase();

        // IssueReport attributes
        final bool matchReportSubject =
            report.reportSubject?.toLowerCase().contains(lowerQuery) ?? false;
        final bool matchReportDescription =
            report.reportDescription?.toLowerCase().contains(lowerQuery) ??
                false;
        final bool matchReportStatus = report.status
                ?.getStatusString()
                .toLowerCase()
                .contains(lowerQuery) ??
            false;
        final bool matchReportReferenceNumber =
            report.referenceNumber?.toLowerCase().contains(lowerQuery) ?? false;

        // CarRental attributes
        final bool matchStartDate =
            rental.startDate?.toString().toLowerCase().contains(lowerQuery) ??
                false;
        final bool matchEndDate =
            rental.endDate?.toString().toLowerCase().contains(lowerQuery) ??
                false;
        final bool matchRentalStatus = rental.status
                ?.getStatusString(UserRole.primaryAdmin)
                .toLowerCase()
                .contains(lowerQuery) ??
            false;
        final bool matchRentalReferenceNumber =
            rental.referenceNumber?.toLowerCase().contains(lowerQuery) ?? false;

        // User attributes
        final bool matchUserFirstName =
            user.userFirstName?.toLowerCase().contains(lowerQuery) ?? false;
        final bool matchUserLastName =
            user.userLastName?.toLowerCase().contains(lowerQuery) ?? false;
        final bool matchUserEmail =
            user.userEmail?.toLowerCase().contains(lowerQuery) ?? false;
        final bool matchUserReferenceNumber =
            user.userReferenceNumber?.toLowerCase().contains(lowerQuery) ??
                false;

        return matchReportSubject ||
            matchReportDescription ||
            matchReportStatus ||
            matchReportReferenceNumber ||
            matchStartDate ||
            matchEndDate ||
            matchRentalStatus ||
            matchRentalReferenceNumber ||
            matchUserFirstName ||
            matchUserLastName ||
            matchUserEmail ||
            matchUserReferenceNumber;
      }).toList();
    }
    notifyListeners();
  }

  void clearFilters() {
    _isSearchFilterActive = false;
    _filteredIssueReports = [];
    notifyListeners();
  }

  bool issueReportsListEquals(List<Map<String, dynamic>> otherList) {
    if (_issueReportsList.length != otherList.length) return false;
    for (int i = 0; i < _issueReportsList.length; i++) {
      if (_issueReportsList[i]['report'].id != otherList[i]['report'].id ||
          _issueReportsList[i]['rental'].id != otherList[i]['rental'].id ||
          _issueReportsList[i]['user'].userId != otherList[i]['user'].userId) {
        return false;
      }
    }
    return true;
  }
}
