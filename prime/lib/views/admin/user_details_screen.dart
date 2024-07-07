// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/models/address.dart';
import 'package:prime/utils/launch_core_service_util.dart';
import 'package:prime/views/profile/view_full_image_screen.dart';
import 'package:prime/widgets/copy_text.dart';
import 'package:prime/widgets/tiles/user_address_tile.dart';
import 'package:provider/provider.dart';
import '../../controllers/user_controller.dart';
import '../../models/user.dart';
import '../../providers/address_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/navigate_with_animation.dart';
import '../../widgets/user_verification_documents.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userId;

  const UserDetailsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  Future<Map<String, dynamic>> fetchUserData({
    required BuildContext context,
    required String userId,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final user = await userProvider.getUserDetails(userId);
    Address? userAddress;
    if (user != null &&
        user.userRole != UserRole.primaryAdmin &&
        user.userRole != UserRole.secondaryAdmin) {
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );
      final userDefaultAddressId =
          await customerProvider.getDefaultAddress(userId);
      final addressProvider = Provider.of<AddressProvider>(
        context,
        listen: false,
      );
      if (userDefaultAddressId.isNotEmpty) {
        userAddress = await addressProvider.getAddressById(
          userDefaultAddressId,
        );
      }
    }
    return {
      'user': user,
      'userAddress': userAddress,
    };
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 100));
          setState(() {});
        },
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchUserData(context: context, userId: widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading user details'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('User not found'));
            }

            final User user = snapshot.data!['user'];
            final Address? userAddress = snapshot.data!['userAddress'];

            return ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 10.0,
              ),
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => animatedPushNavigation(
                        context: context,
                        screen: ViewFullImageScreen(
                          imageUrl: user.userProfileUrl ??
                              UserController().defaultProfileUrl,
                          appBarTitle: 'Profile Image',
                          tag: 'user-profile-image',
                        ),
                      ),
                      child: Hero(
                        tag: 'user-profile-image',
                        child: ClipOval(
                          child: CircleAvatar(
                            radius: 50.0,
                            child: CachedNetworkImage(
                              imageUrl: user.userProfileUrl ??
                                  UserController().defaultProfileUrl,
                              width: 155,
                              height: 155,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.person),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.userFirstName} ${user.userLastName}',
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: user.userActivityStatus ==
                                        ActivityStatus.active
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Activity Status Text
                            Text(
                              user.userActivityStatus?.toReadableString() ?? '',
                              style: TextStyle(
                                color: user.userActivityStatus ==
                                        ActivityStatus.active
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Text('Role: ${user.userRole?.toReadableString()}'),
                        const SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text('Ref No'),
                            const SizedBox(width: 5.0),
                            CopyText(
                              text: user.userReferenceNumber ?? 'N/A',
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          'Date Joined ${DateFormat.yMMMd().add_jm().format(user.createdAt as DateTime)}',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: user.userPhoneNumber == null ||
                              user.userPhoneNumber!.isEmpty
                          ? null
                          : () => LaunchCoreServiceUtil.launchPhoneCall(
                              user.userPhoneNumber!),
                      icon: const Icon(Icons.phone),
                      label: Text(
                        user.userPhoneNumber == null ||
                                user.userPhoneNumber!.isEmpty
                            ? 'N/A'
                            : user.userPhoneNumber!,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: user.userEmail == null
                          ? null
                          : () => LaunchCoreServiceUtil.launchEmail(
                              user.userEmail!),
                      icon: const Icon(Icons.email),
                      label: Text(user.userEmail ?? ''),
                    ),
                  ],
                ),
                if (user.userRole != UserRole.primaryAdmin &&
                    user.userRole != UserRole.secondaryAdmin)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: Text(
                      'User Address',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (user.userRole != UserRole.primaryAdmin &&
                    user.userRole != UserRole.secondaryAdmin)
                  UserAddressTile(address: userAddress),
                const SizedBox(height: 20.0),
                if (user.userRole != UserRole.primaryAdmin &&
                    user.userRole != UserRole.secondaryAdmin)
                  UserVerificationDocuments(userId: user.userId as String),
              ],
            );
          },
        ),
      ),
    );
  }
}
