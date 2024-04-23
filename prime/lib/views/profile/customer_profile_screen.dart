import 'package:flutter/material.dart';
import 'package:prime/widgets/tiles/notification_switch.dart';
import 'package:prime/widgets/user_info.dart';

import '../../widgets/tiles/address_tile.dart';
import '../../widgets/tiles/edit_profile_tile.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/tiles/sign_out_tile.dart';
import '../../widgets/tiles/dark_mode_switch.dart';
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
          ListTile(
            leading: const Icon(Icons.lock_rounded),
            title: const Text(
              'Change Password',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right_rounded),
            onTap: () {},
          ),
          const AddressTile(),
          const NotificationsSwitch(),
          ListTile(
            leading: const Icon(Icons.payment_rounded),
            title: const Text(
              'Payment & Bank Details',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right_rounded),
            onTap: () {},
          ),
          const DarkModeSwitch(),
          ListTile(
            leading: const Icon(Icons.lock_person),
            title: const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right_rounded),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_rounded),
            title: const Text(
              'Help Center',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right_rounded),
            onTap: () {},
          ),
          const SizedBox(height: 15),
          SignOutTile(),
          const SizedBox(height: 15),
        ],
      ),
      bottomNavigationBar: const CustomerNavigationBar(currentIndex: 3),
    );
  }
}
