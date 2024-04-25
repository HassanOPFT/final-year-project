import 'package:flutter/material.dart';
import 'package:prime/widgets/tiles/notification_switch.dart';
import 'package:prime/widgets/user_info.dart';

import '../../widgets/tiles/address_tile.dart';
import '../../widgets/tiles/change_password_tile.dart';
import '../../widgets/tiles/edit_profile_tile.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/tiles/help_center_tile.dart';
import '../../widgets/tiles/payment_and_bank_details_tile.dart';
import '../../widgets/tiles/personal_documents_tile.dart';
import '../../widgets/tiles/privacy_policy_tile.dart';
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
          const ChangePasswordTile(),
          const AddressTile(),
          const PersonalDocumentsTile(), // make tabs for each document type
          const NotificationsSwitch(),
          const PaymentAndBankDetails(),
          const DarkModeSwitch(),
          const PrivacyPolicyTile(),
          const HelpCenterTile(),
          const SizedBox(height: 15),
          SignOutTile(),
          const SizedBox(height: 15),
        ],
      ),
      bottomNavigationBar: const CustomerNavigationBar(currentIndex: 3),
    );
  }
}





