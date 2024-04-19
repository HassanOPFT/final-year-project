import 'package:flutter/material.dart';
import 'package:prime/widgets/navigation_bar/admin_navigation_bar.dart';

class AdminProfileScreen extends StatelessWidget {

  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text('Profile'),
      ),
      bottomNavigationBar: const AdminNavigationBar(currentIndex: 4),
    );
  }
}
