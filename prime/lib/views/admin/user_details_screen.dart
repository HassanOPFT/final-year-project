import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/utils/launch_core_service_util.dart';
import 'package:prime/views/profile/view_full_image_screen.dart';
import 'package:prime/widgets/copy_text.dart';
import '../../controllers/user_controller.dart';
import '../../models/user.dart';
import '../../utils/navigate_with_animation.dart';
import '../../widgets/user_verification_documents.dart';

class UserDetailsScreen extends StatelessWidget {
  final User user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                            color:
                                user.userActivityStatus == ActivityStatus.active
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Activity Status Text
                        Text(
                          user.userActivityStatus?.toReadableString() ?? '',
                          style: TextStyle(
                            color:
                                user.userActivityStatus == ActivityStatus.active
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      'Role: ${user.userRole?.toReadableString()}',
                    ),
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
                      'Date Joined: ${DateFormat.yMMMd().add_jm().format(user.createdAt as DateTime)}',
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
            TextButton.icon(
              onPressed:
                  user.userPhoneNumber == null || user.userPhoneNumber!.isEmpty
                      ? null
                      : () => LaunchCoreServiceUtil.launchPhoneCall(
                            user.userPhoneNumber!,
                          ),
              icon: const Icon(Icons.phone),
              label: Text(
                user.userPhoneNumber == null || user.userPhoneNumber!.isEmpty
                    ? 'N/A'
                    : user.userPhoneNumber!,
              ),
            ),
            TextButton.icon(
              onPressed: user.userEmail == null
                  ? null
                  : () => LaunchCoreServiceUtil.launchEmail(
                        user.userEmail!,
                      ),
              icon: const Icon(Icons.email),
              label: Text(user.userEmail ?? ''),
            ),
            const SizedBox(height: 20.0),
            if (user.userRole != UserRole.primaryAdmin &&
                user.userRole != UserRole.secondaryAdmin)
              UserVerificationDocuments(userId: user.userId as String),
          ],
        ),
      ),
    );
  }
}
