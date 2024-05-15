import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils/navigate_with_animation.dart';
import '../utils/snackbar.dart';
import '../views/common/full_screen_image_screen.dart';
import 'bottom_sheet/select_image_bottom_sheet.dart';

class ChooseImageContainer extends StatefulWidget {
  final Function(File?) setSelectedImage;
  const ChooseImageContainer({
    super.key,
    required this.setSelectedImage,
  });

  @override
  State<ChooseImageContainer> createState() => _ChooseImageContainerState();
}

class _ChooseImageContainerState extends State<ChooseImageContainer> {
  File? _selectedImage;
  final _imagePicker = ImagePicker();

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
      );

      if (croppedFile == null) return;

      final compressedFile = await _compressImage(croppedFile.path, 35);
      if (compressedFile == null) return;
      setState(() {
        _selectedImage = File(compressedFile.path);
      });
      widget.setSelectedImage(_selectedImage);
    } catch (e) {
      if (mounted) {
        buildFailureSnackbar(
          context: context,
          message: 'Error while picking image. Please try again.',
        );
      }
    }
  }

  Future<void> showSelectImageBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SelectImageBottomSheet(pickImage: pickImage);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _selectedImage != null
              ? () => animatedPushNavigation(
                    context: context,
                    screen: FullScreenImageScreen(
                      imagePath: _selectedImage!.path,
                      appBarTitle: 'Selected Image',
                      tag: 'full-screen-image',
                    ),
                  )
              : showSelectImageBottomSheet,
          child: Hero(
            tag: 'full-screen-image',
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
                borderRadius: BorderRadius.circular(15.0),
                image: _selectedImage != null
                    ? DecorationImage(
                        image: FileImage(
                          File(_selectedImage!.path),
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _selectedImage == null
                  ? Center(
                      child: TextButton.icon(
                        onPressed: showSelectImageBottomSheet,
                        icon: const Icon(Icons.image_rounded),
                        label: const Text(
                          'Choose Image',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
        if (_selectedImage != null) const SizedBox(height: 10),
        if (_selectedImage != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: showSelectImageBottomSheet,
                icon: const Icon(Icons.change_circle_rounded),
                label: const Text(
                  'Change',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                  });
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
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
      ],
    );
  }
}
