import 'package:flutter/material.dart';
import 'package:prime/widgets/navigation_bar/admin_navigation_bar.dart';

import '../../widgets/app_logo.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const AppLogo(height: 120),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Dashboard'),
      ),
      bottomNavigationBar: const AdminNavigationBar(currentIndex: 0),
    );
  }
}
