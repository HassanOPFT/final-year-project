import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImageScreen extends StatelessWidget {
  final String imagePath;
  final String tag;
  final String appBarTitle;

  const FullScreenImageScreen({
    super.key,
    required this.appBarTitle,
    required this.tag,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: InteractiveViewer(
        child: Center(
          child: Hero(
            tag: tag,
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
