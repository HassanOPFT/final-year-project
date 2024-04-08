import 'package:flutter/material.dart';

import '../../widgets/navigation_bar/customer_navigation_bar.dart';

class CustomerProfileScreen extends StatelessWidget {
  static const routeName = '/customer-profile';

  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text('Profile'),
      ),
      bottomNavigationBar: const CustomerNavigationBar(currentIndex: 3),
    );
  }
}
