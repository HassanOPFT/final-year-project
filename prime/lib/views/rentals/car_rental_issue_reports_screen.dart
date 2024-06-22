import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/issue_report.dart';
import '../../models/user.dart';
import '../../providers/issue_report_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_progress_indicator.dart';
import '../../widgets/tiles/issue_report_tile.dart';

class CarRentalIssueReportsScreen extends StatelessWidget {
  final String carRentalId;

  const CarRentalIssueReportsScreen({super.key, required this.carRentalId});

  @override
  Widget build(BuildContext context) {
    Future<List<Map<String, dynamic>>> fetchIssueReportsWithUsers(
        String carRentalId) async {
      final issueReportProvider = Provider.of<IssueReportProvider>(
        context,
        listen: false,
      );
      final userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );

      final issueReports =
          await issueReportProvider.getIssueReportsByCarRentalId(carRentalId);
      final List<Map<String, dynamic>> issueReportsWithUsers = [];

      for (var report in issueReports) {
        User? reporterDetails;
        if (report.reporterId != null) {
          reporterDetails =
              await userProvider.getUserDetails(report.reporterId!);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Reports'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchIssueReportsWithUsers(carRentalId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomProgressIndicator();
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading data'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No issue reports available'),
            );
          } else {
            final issueReportsWithUsers = snapshot.data!;
            return ListView.builder(
              itemCount: issueReportsWithUsers.length,
              padding: const EdgeInsets.all(10.0),
              itemBuilder: (context, index) {
                final issueReport =
                    issueReportsWithUsers[index]['issueReport'] as IssueReport;
                final userFullName =
                    issueReportsWithUsers[index]['userFullName'] as String;

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
