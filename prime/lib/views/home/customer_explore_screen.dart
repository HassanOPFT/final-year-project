import 'package:flutter/material.dart';

import '../../widgets/navigation_bar/customer_navigation_bar.dart';

class CustomerExploreScreen extends StatelessWidget {
  static const routeName = '/customer-explore';

  const CustomerExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      body: const Center(
        child: Text('Explore'),
      ),
      bottomNavigationBar: const CustomerNavigationBar(currentIndex: 0),
    );
  }
}
