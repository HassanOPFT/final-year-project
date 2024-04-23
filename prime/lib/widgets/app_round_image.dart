import 'dart:typed_data';

import 'package:flutter/material.dart';

class AppRoundImage extends StatelessWidget {
  final ImageProvider imageProvider;
  final double height;
  final double width;
  const AppRoundImage({
    required this.imageProvider,
    super.key,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Image(
        image: imageProvider,
        height: height,
        width: width,
      ),
    );
  }

  factory AppRoundImage.url({
    required String imageUrl,
    required double height,
    required double width,
  }) {
    return AppRoundImage(
      imageProvider: NetworkImage(imageUrl),
      height: height,
      width: width,
    );
  }

  factory AppRoundImage.memory({
    required Uint8List data,
    required double height,
    required double width,
  }) {
    return AppRoundImage(
      imageProvider: MemoryImage(data),
      height: height,
      width: width,
    );
  }
}
