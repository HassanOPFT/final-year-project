import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../utils/navigate_with_animation.dart';
import '../../utils/snackbar.dart';
import '../../views/common/full_screen_image_screen.dart';
import '../bottom_sheet/select_image_bottom_sheet.dart';

class UpdateCarImages extends StatefulWidget {
  final Function(List<String>) onImagesChanged;
  final List<String> initialImageUrls;

  const UpdateCarImages({
    super.key,
    required this.onImagesChanged,
    required this.initialImageUrls,
  });

  @override
  State<UpdateCarImages> createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<UpdateCarImages> {
  final List<dynamic> _selectedImages =
      []; // List to store both URLs and local file paths
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedImages
        .addAll(widget.initialImageUrls); // Add initial URLs to the list
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
      );

      if (croppedFile == null) return;

      final compressedFile = await _compressImage(croppedFile.path, 35);
      if (compressedFile == null) return;

      setState(() {
        _selectedImages.add(File(compressedFile.path));
      });

      widget.onImagesChanged(_getImagePaths());
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

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    widget.onImagesChanged(_getImagePaths());
  }

  List<String> _getImagePaths() {
    return _selectedImages.map((image) {
      if (image is String) {
        return image; // URL
      } else if (image is File) {
        return image.path; // Local file path
      }
      return '';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: _selectedImages.length + 1,
      itemBuilder: (context, index) {
        if (index == _selectedImages.length) {
          return GestureDetector(
            onTap: showSelectImageBottomSheet,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  TextButton(
                    onPressed: showSelectImageBottomSheet,
                    child: const Text(
                      'Add Image',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          final image = _selectedImages[index];
          return Stack(
            children: [
              GestureDetector(
                onTap: () => animatedPushNavigation(
                  context: context,
                  screen: FullScreenImageScreen(
                    imagePath: image is String ? image : image.path,
                    appBarTitle: 'Selected Image',
                    tag: 'full-screen-image-$index',
                  ),
                ),
                child: Hero(
                  tag: 'full-screen-image-$index',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      image: DecorationImage(
                        image: image is String
                            ? NetworkImage(image)
                            : FileImage(image) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: const CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.delete,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
