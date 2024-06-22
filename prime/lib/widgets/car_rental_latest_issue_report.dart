import 'package:flutter/material.dart';
import 'package:prime/services/firebase/firebase_auth_service.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/views/rentals/car_rental_issue_reports_screen.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';
import '../../models/issue_report.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import 'tiles/issue_report_tile.dart';
import 'tiles/latest_issue_report_tile.dart';

class CarRentalLatestIssueReport extends StatelessWidget {
  final IssueReport latestIssueReport;
  final String carRentalId;

  const CarRentalLatestIssueReport({
    super.key,
    required this.latestIssueReport,
    required this.carRentalId,
  });

  @override
  Widget build(BuildContext context) {
    Future<Map<String, dynamic>> fetchCombinedData(String carRentalId) async {
      final userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );
      User? reporterDetails;
      if (latestIssueReport.reporterId != null) {
        reporterDetails = await userProvider.getUserDetails(
          latestIssueReport.reporterId ?? '',
        );
      }

      return {
        'latestIssueReport': latestIssueReport,
        'reporterDetails': reporterDetails,
      };
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Issue Report',
              style: TextStyle(
                fontSize: 24.0,
              ),
            ),
            const SizedBox(height: 10.0),
            FutureBuilder<Map<String, dynamic>>(
              future: fetchCombinedData(carRentalId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CustomProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading data'),
                  );
                } else if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!['latestIssueReport'] == null) {
                  return const Center(
                    child: Text('No issue report available'),
                  );
                } else {
                  final issueReport =
                      snapshot.data!['latestIssueReport'] as IssueReport;
                  final User? reporterDetails =
                      snapshot.data!['reporterDetails'];

                  final userFullName = reporterDetails != null
                      ? '${reporterDetails.userFirstName ?? ''} ${reporterDetails.userLastName ?? ''}'
                      : 'Unknown User';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LatestIssueReportTile(
                        issueReport: issueReport,
                        userFullName: userFullName,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => animatedPushNavigation(
                              context: context,
                              screen: CarRentalIssueReportsScreen(
                                carRentalId: issueReport.carRentalId ?? '',
                              ),
                            ),
                            child: const Text(
                              'View All Reports',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
