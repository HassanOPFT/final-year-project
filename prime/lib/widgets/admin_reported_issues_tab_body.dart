import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/issue_report.dart';
import '../models/user.dart';
import '../providers/issue_report_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_progress_indicator.dart';
import '../widgets/no_data_found.dart';
import '../widgets/tiles/issue_report_tile.dart';

class AdminReportedIssuesTabBody extends StatelessWidget {
  const AdminReportedIssuesTabBody({super.key});

  Future<List<Map<String, dynamic>>> fetchIssueReportsWithUsers(
    BuildContext context,
  ) async {
    final issueReportProvider = Provider.of<IssueReportProvider>(context);
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    final issueReports = await issueReportProvider.getAllIssueReports();
    final List<Map<String, dynamic>> issueReportsWithUsers = [];

    for (var report in issueReports) {
      User? reporterDetails;
      if (report.reporterId != null) {
        reporterDetails = await userProvider.getUserDetails(report.reporterId!);
      }
      final userFullName = reporterDetails != null
          ? '${reporterDetails.userFirstName ?? ''} ${reporterDetails.userLastName ?? ''}'
          : 'Unknown User';

      issueReportsWithUsers.add({
        'issueReport': report,
        'userFullName': userFullName,
      });
    }

    return issueReportsWithUsers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchIssueReportsWithUsers(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomProgressIndicator();
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading data'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const NoDataFound(
              title: 'Nothing Found',
              subTitle: 'No rentals reported issues found.',
            );
          } else {
            final issueReportsWithUsers = snapshot.data!;
            return ListView.builder(
              itemCount: issueReportsWithUsers.length,
              padding: const EdgeInsets.all(10.0),
              itemBuilder: (context, index) {
                final IssueReport issueReport =
                    issueReportsWithUsers[index]['issueReport'];
                final String userFullName =
                    issueReportsWithUsers[index]['userFullName'];

                return IssueReportTile(
                  issueReport: issueReport,
                  userFullName: userFullName,
                );
              },
            );
          }
        },
      ),
    );
  }
}
