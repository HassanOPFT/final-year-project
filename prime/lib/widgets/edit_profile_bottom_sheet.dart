import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileBottomSheet extends StatelessWidget {
  final bool isDefaultProfile;
  final Function(ImageSource) pickImage;
  final Function deleteImage;
  const EditProfileBottomSheet({
    super.key,
    required this.isDefaultProfile,
    required this.pickImage,
    required this.deleteImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Edit Profile',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5.0),
          const Divider(),
          const SizedBox(height: 15.0),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              pickImage(ImageSource.gallery);
            },
            icon: const Icon(Icons.upload_rounded),
            label: const Text(
              'Upload Image',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              pickImage(ImageSource.camera);
            },
            icon: const Icon(Icons.camera),
            label: const Text(
              'Take Image',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
          if (isDefaultProfile)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                deleteImage();
              },
              icon: const Icon(
                Icons.delete_rounded,
                color: Colors.red,
              ),
              label: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
