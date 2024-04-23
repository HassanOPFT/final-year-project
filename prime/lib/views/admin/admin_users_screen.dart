import 'package:flutter/material.dart';
import 'package:prime/widgets/navigation_bar/admin_navigation_bar.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: const Center(
        child: Text('Users'),
      ),
      bottomNavigationBar: const AdminNavigationBar(currentIndex: 3),
    );
  }
}
