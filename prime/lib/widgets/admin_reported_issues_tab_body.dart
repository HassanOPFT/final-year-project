import 'package:flutter/material.dart';

import 'no_data_found.dart';

class AdminReportedIssuesTabBody extends StatelessWidget {
  const AdminReportedIssuesTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const NoDataFound(
      title: 'Nothing Found',
      subTitle: 'No rentals reported issues found.',
    );
  }
}
