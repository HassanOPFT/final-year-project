import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:prime/controllers/user_controller.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/views/admin/user_details_screen.dart';

import '../../models/customer.dart';
import '../../models/user.dart';

class UserDetailsTile extends StatelessWidget {
  final User user;

  const UserDetailsTile({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        '${user.userFirstName ?? ''} ${user.userLastName ?? ''}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.userEmail ?? '',
          ),
          const SizedBox(height: 4),
          Text(
            user.userRole?.toReadableString() ?? '',
          ),
        ],
      ),
      leading: CircleAvatar(
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: user.userProfileUrl ?? UserController().defaultProfileUrl,
            width: 155,
            height: 155,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.person),
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: user.userActivityStatus == ActivityStatus.active
                  ? Colors.green
                  : Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          // Activity Status Text
          Text(
            user.userActivityStatus?.toReadableString() ?? '',
            style: TextStyle(
              color: user.userActivityStatus == ActivityStatus.active
                  ? Colors.green
                  : Colors.red,
            ),
          ),
        ],
      ),
      onTap: () {
        animatedPushNavigation(
          context: context,
          screen: UserDetailsScreen(userId: user.userId ?? ''),
        );
      },
    );
  }
}
