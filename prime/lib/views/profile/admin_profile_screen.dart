import 'package:flutter/material.dart';
import 'package:prime/widgets/navigation_bar/admin_navigation_bar.dart';

import '../../widgets/profile_avatar.dart';
import '../../widgets/tiles/change_password_tile.dart';
import '../../widgets/tiles/dark_mode_switch.dart';
import '../../widgets/tiles/edit_profile_tile.dart';
import '../../widgets/tiles/notification_switch.dart';
import '../../widgets/tiles/sign_out_tile.dart';
import '../../widgets/user_info.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          const ProfileAvatar(),
          const SizedBox(height: 15),
          const UserInfo(),
          const SizedBox(height: 25),
          const Divider(
            endIndent: 15,
            indent: 15,
          ),
          const EditProfileTile(),
          const ChangePasswordTile(),
          // const AddressTile(),
          const NotificationsSwitch(),
          const DarkModeSwitch(),
          const SizedBox(height: 15),
          SignOutTile(),
          const SizedBox(height: 15),
        ],
      ),
      bottomNavigationBar: const AdminNavigationBar(currentIndex: 4),
    );
  }
}
