import 'package:flutter/material.dart';
import 'package:prime/widgets/navigation_bar/admin_navigation_bar.dart';

class AdminCarsScreen extends StatelessWidget {

  const AdminCarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cars'),
      ),
      body: const Center(
        child: Text('Cars'),
      ),
      bottomNavigationBar: const AdminNavigationBar(currentIndex: 2),
    );
  }
}
