import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SelectImageBottomSheet extends StatelessWidget {
  final Function(ImageSource) pickImage;

  const SelectImageBottomSheet({super.key, required this.pickImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Select Image',
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
            icon: const Icon(Icons.camera_rounded),
            label: const Text(
              'Take Image',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
