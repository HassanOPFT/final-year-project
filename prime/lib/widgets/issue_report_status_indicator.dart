import 'package:flutter/material.dart';
import '../models/issue_report.dart';

class IssueReportStatusIndicator extends StatelessWidget {
  final IssueReportStatus issueReportStatus;

  const IssueReportStatusIndicator({
    super.key,
    required this.issueReportStatus,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (issueReportStatus) {
      case IssueReportStatus.open:
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade900;
        break;
      case IssueReportStatus.inProgress:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade900;
        break;
      case IssueReportStatus.resolved:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade900;
        break;
      case IssueReportStatus.closed:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade900;
        break;
      default:
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade900;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Text(
        issueReportStatus.getStatusString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.0,
          color: textColor,
        ),
      ),
    );
  }
}
