import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/views/profile/view_full_image_screen.dart';

import '../controllers/user_controller.dart';
import '../services/firebase/firebase_auth_service.dart';
import 'edit_profile_bottom_sheet.dart';

class ProfileAvatar extends StatefulWidget {
  const ProfileAvatar({super.key});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  final authService = FirebaseAuthService();
  final userController = UserController();
  String? userProfileUrl;
  static const defaultProfileUrl =
      'https://firebasestorage.googleapis.com/v0/b/prime-b09b7.appspot.com/o/default-files%2Fuser-default-profile-picture.jpg?alt=media&token=4acacd32-a06e-4637-a5af-357c986caca3';

  @override
  void initState() {
    super.initState();
    _loadUserProfileUrl();
  }

  void _loadUserProfileUrl() async {
    final currentUser = authService.currentUser;
    if (currentUser != null) {
      final profileUrl =
          await userController.getUserProfilePicture(currentUser.uid);
      setState(() {
        userProfileUrl = profileUrl ?? defaultProfileUrl;
        if (userProfileUrl != null && userProfileUrl!.isEmpty) {
          userProfileUrl = defaultProfileUrl;
        }
      });
    } else {
      setState(() {
        userProfileUrl = defaultProfileUrl;
      });
    }
  }

  void _showEditProfileBottomSheet() {
    final isProfileDefault = userProfileUrl != defaultProfileUrl;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return EditProfileBottomSheet(isProfileDefault: isProfileDefault);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeOfContext = Theme.of(context);
    userProfileUrl = userProfileUrl ?? defaultProfileUrl;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () {
                animatedPushNavigation(
                  context: context,
                  screen: ViewFullImageScreen(imageUrl: userProfileUrl!),
                );
              },
              child: Hero(
                tag: 'profile-image',
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.teal,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: userProfileUrl!,
                      width: 155,
                      height: 155,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0.0,
              bottom: 0.0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: themeOfContext.colorScheme.primaryContainer,
                ),
                child: IconButton(
                  onPressed: _showEditProfileBottomSheet,
                  color: themeOfContext.colorScheme.primary,
                  icon: const Icon(Icons.edit_rounded),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
