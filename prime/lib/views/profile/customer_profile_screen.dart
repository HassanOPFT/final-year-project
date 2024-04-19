import 'package:flutter/material.dart';

import '../../widgets/sign_out_tile.dart';
import '../../widgets/dark_mode_switch.dart';
import '../../widgets/navigation_bar/customer_navigation_bar.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const DarkModeSwitch(),
          SignOutTile(),
        ],
      ),
      bottomNavigationBar: const CustomerNavigationBar(currentIndex: 3),
    );
  }
}
