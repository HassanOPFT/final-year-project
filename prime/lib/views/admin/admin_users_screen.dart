import 'package:flutter/material.dart';
import '../../widgets/admins_tab_body.dart';
import '../../widgets/customers_tab_body.dart';
import '../../widgets/navigation_bar/admin_navigation_bar.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Users'),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Customers',
                icon: Icon(Icons.person),
              ),
              Tab(
                text: 'Admins',
                icon: Icon(Icons.admin_panel_settings_rounded),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CustomersTabBody(),
            AdminsTabBody(),
          ],
        ),
        bottomNavigationBar: const AdminNavigationBar(currentIndex: 3),
      ),
    );
  }
}
