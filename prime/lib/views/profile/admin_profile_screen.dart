import 'package:flutter/material.dart';
import 'package:prime/widgets/navigation_bar/admin_navigation_bar.dart';

import '../../widgets/tiles/dark_mode_switch.dart';
import '../../widgets/tiles/sign_out_tile.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

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
      bottomNavigationBar: const AdminNavigationBar(currentIndex: 4),
    );
  }
}
