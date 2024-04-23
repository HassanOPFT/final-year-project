import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_round_image.dart';

class UserImage extends StatefulWidget {
  final Function(String imageUrl) onFileChanged;
  const UserImage({Key? key, required this.onFileChanged}) : super(key: key);

  @override
  State<UserImage> createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  final _imagePicker = ImagePicker();
  String? imageUrl;

  Future<void> _uploadFile(String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('test').child('${DateTime.now().toIso8601String()}${p.basename(path)}');
      final result = await ref.putFile(File(path));
      final fileUrl = await result.ref.getDownloadURL();
      setState(() {
        imageUrl = fileUrl;
      });
      widget.onFileChanged(fileUrl);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading image')));
    }
  }

  Future<XFile?> _compressImage(String path, int quality) async {
    try {
      final newPath = p.join((await getTemporaryDirectory()).path, '${DateTime.now()}${p.extension(path)}');
      final result = await FlutterImageCompress.compressAndGetFile(path, newPath, quality: quality);
      return result;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error compressing image')));
      return null;
    }
  }

  Future<void> _pickImage(ImageSource imageSource) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: imageSource, imageQuality: 50);
      if (pickedFile == null) return;

      final imageCropper = ImageCropper();
      final croppedFile = await imageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      );

      if (croppedFile == null) return;

      final compressedFile = await _compressImage(croppedFile.path, 35);
      if (compressedFile == null) return;

      await _uploadFile(compressedFile.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image')));
    }
  }

  Future<void> _selectPhoto() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => BottomSheet(
        onClosing: () {},
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.filter),
              title: const Text('Select from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imageUrl == null)
          Icon(
            Icons.image,
            size: 100.0,
            color: Theme.of(context).colorScheme.primary,
          ),
        if (imageUrl != null)
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () => _selectPhoto(),
            child: AppRoundImage.url(
              imageUrl: imageUrl!,
              width: 80,
              height: 80,
            ),
          ),
        InkWell(
          onTap: () => _selectPhoto(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              imageUrl != null ? 'Change Photo' : 'Select Photo',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ],
    );
  }
}
