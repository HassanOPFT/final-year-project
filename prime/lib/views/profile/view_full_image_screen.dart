import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ViewFullImageScreen extends StatelessWidget {
  final String appBarTitle;
  final String tag;
  final String imageUrl;

  const ViewFullImageScreen({
    super.key,
    required this.imageUrl,
    required this.appBarTitle,
    required this.tag,
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
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }
}
