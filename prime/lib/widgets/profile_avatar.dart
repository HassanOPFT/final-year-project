import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/views/profile/view_full_image_screen.dart';
import 'package:path/path.dart' as p;

import '../controllers/user_controller.dart';
import '../services/firebase/firebase_auth_service.dart';
import '../utils/snackbar.dart';
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
  late String defaultProfileUrl;
  late String? userId;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    defaultProfileUrl = userController.defaultProfileUrl;
    userId = authService.currentUser?.uid;
    _loadUserProfileUrl();
  }

  void deleteImage() async {
    try {
      if (userProfileUrl == defaultProfileUrl) {
        return;
      }

      if (userId != null) {
        await userController.deleteProfilePicture(userId!);
        setState(() {
          userProfileUrl = defaultProfileUrl;
        });
      } else {
        if (mounted) {
          buildFailureSnackbar(
            context: context,
            message: 'Error while deleting image. Please try again.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        buildFailureSnackbar(
          context: context,
          message: 'Error while deleting image. Please try again.',
        );
      }
    }
  }

  Future<XFile?> _compressImage(String path, int quality) async {
    try {
      final newPath = p.join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}${p.extension(path)}',
      );
      final result = await FlutterImageCompress.compressAndGetFile(
        path,
        newPath,
        quality: quality,
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pickImage(ImageSource imageSource) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: imageSource,
        imageQuality: 50,
      );
      if (pickedFile == null) return;

      final imageCropper = ImageCropper();
      final croppedFile = await imageCropper.cropImage(
        sourcePath: pickedFile.path,
        // aspectRatio: const CropAspectRatio(
        //   ratioX: 1,
        //   ratioY: 1,
        // ),
      );

      if (croppedFile == null) return;

      final compressedFile = await _compressImage(croppedFile.path, 35);
      if (compressedFile == null) return;

      // Upload the image to Firebase Storage
      if (userId != null) {
        final newProfileImage = await userController.uploadProfilePicture(
          compressedFile.path,
          userId as String,
        );
        setState(() {
          userProfileUrl = newProfileImage;
        });
      } else {
        if (mounted) {
          buildFailureSnackbar(
            context: context,
            message: 'Error while picking image. Please try again.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        buildFailureSnackbar(
          context: context,
          message: 'Error while picking image. Please try again.',
        );
      }
    }
  }

  void _loadUserProfileUrl() async {
    if (userId != null) {
      final profileUrl =
          await userController.getUserProfilePicture(userId as String);
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

  Future<void> _showEditProfileBottomSheet() async {
    final isDefaultProfile = userProfileUrl != defaultProfileUrl;

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return EditProfileBottomSheet(
          isDefaultProfile: isDefaultProfile,
          pickImage: pickImage,
          deleteImage: deleteImage,
        );
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
                  screen: ViewFullImageScreen(
                    imageUrl: userProfileUrl!,
                    appBarTitle: 'Profile Image',
                    tag: 'profile-image',
                  ),
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
              right: 5.0,
              bottom: 5.0,
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
