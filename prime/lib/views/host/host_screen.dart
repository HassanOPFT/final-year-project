import 'package:flutter/material.dart';

import '../../widgets/navigation_bar/customer_navigation_bar.dart';

class HostScreen extends StatelessWidget {

  const HostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Host'),
      ),
      body: const Center(
        child: Text('Host'),
      ),
      bottomNavigationBar: const CustomerNavigationBar(currentIndex: 2),
    );
  }
}
