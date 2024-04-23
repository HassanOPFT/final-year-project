import 'package:flutter/material.dart';

class EditProfileBottomSheet extends StatelessWidget {
  final bool isProfileDefault;
  const EditProfileBottomSheet({super.key, required this.isProfileDefault});

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
            onPressed: () {},
            icon: const Icon(Icons.upload_rounded),
            label: const Text(
              'Upload Image',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.camera),
            label: const Text(
              'Take Image',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
          if (isProfileDefault)
            TextButton.icon(
              onPressed: () {},
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
