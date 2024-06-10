import 'package:flutter/material.dart';
import 'package:prime/widgets/navigation_bar/admin_navigation_bar.dart';

class AdminRentalsScreen extends StatelessWidget {
  const AdminRentalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rentals'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Rentals'),
      ),
      bottomNavigationBar: const AdminNavigationBar(currentIndex: 1),
    );
  }
}
