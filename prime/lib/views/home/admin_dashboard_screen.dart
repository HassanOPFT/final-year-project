import 'package:flutter/material.dart';
import 'package:prime/widgets/navigation_bar/admin_navigation_bar.dart';

class AdminDashboardScreen extends StatelessWidget {

  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: const Center(
        child: Text('Dashboard'),
      ),
      bottomNavigationBar: const AdminNavigationBar(currentIndex: 0),
    );
  }
}
