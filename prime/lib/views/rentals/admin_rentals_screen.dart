import 'package:flutter/material.dart';
import 'package:prime/widgets/navigation_bar/admin_navigation_bar.dart';

import '../../widgets/admin_active_car_rentals_tab_body.dart';
import '../../widgets/admin_car_rentals_history_tab_body.dart';
import '../../widgets/admin_reported_issues_tab_body.dart';

class AdminRentalsScreen extends StatelessWidget {
  final int initialTab;
  const AdminRentalsScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialTab,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            title: const Text('Rentals'),
            automaticallyImplyLeading: false,
            bottom: const TabBar(
              tabs: [
                Tab(
                  text: 'Active',
                  icon: Icon(Icons.directions_car_rounded),
                ),
                Tab(
                  text: 'History',
                  icon: Icon(Icons.history_rounded),
                ),
                Tab(
                  text: 'Reported Issues',
                  icon: Icon(Icons.report_problem_rounded),
                ),
              ],
            )),
        body: const TabBarView(
          children: [
            AdminActiveCarRentalsTabBody(),
            AdminCarRentalsHistoryTabBody(),
            AdminReportedIssuesTabBody(),
          ],
        ),
        bottomNavigationBar: const AdminNavigationBar(currentIndex: 1),
      ),
    );
  }
}
