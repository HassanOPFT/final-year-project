import 'package:flutter/material.dart';

import '../../widgets/navigation_bar/customer_navigation_bar.dart';

class CustomerRentalsScreen extends StatelessWidget {

  const CustomerRentalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rentals'),
      ),
      body: const Center(
        child: Text('Rentals'),
      ),
      bottomNavigationBar: const CustomerNavigationBar(currentIndex: 1),
    );
  }
}
