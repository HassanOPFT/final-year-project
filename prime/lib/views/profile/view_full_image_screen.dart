import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ViewFullImageScreen extends StatelessWidget {
  const ViewFullImageScreen({
    super.key,
    required this.imageUrl,
  });
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Image'),
      ),
      body: Center(
        child: Hero(
          tag: 'profile-image',
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}
