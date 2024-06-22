import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/utils/navigate_with_animation.dart';

import '../../models/issue_report.dart';
import '../../views/rentals/issue_report_details_screen.dart';
import '../issue_report_status_indicator.dart';

class IssueReportTile extends StatelessWidget {
  final IssueReport issueReport;
  final String userFullName;

  const IssueReportTile({
    super.key,
    required this.issueReport,
    required this.userFullName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => animatedPushNavigation(
        context: context,
        screen: IssueReportDetailsScreen(
          issueReportId: issueReport.id ?? '',
        ),
      ),
      child: Card(
        child: ListTile(
          leading: Icon(
            Icons.report_problem,
            size: 30.0,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            issueReport.reportSubject ?? 'No Subject',
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              IssueReportStatusIndicator(
                issueReportStatus:
                    issueReport.status ?? IssueReportStatus.inProgress,
              ),
              Text(
                issueReport.createdAt != null
                    ? DateFormat.yMMMd().add_jm().format(issueReport.createdAt!)
                    : 'Unknown',
                style: TextStyle(
                  fontSize: 13.0,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ],
          ),
          trailing: Text(
            userFullName,
            style: TextStyle(
              fontSize: 13.0,
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
      ),
    );
  }
}
