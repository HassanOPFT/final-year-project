import 'package:flutter/material.dart';

import '../utils/assets_paths.dart';

class AppLogo extends StatelessWidget {
  final double? height;
  final double? width;
  final double? scale;

  const AppLogo({
    super.key,
    this.height,
    this.width,
    this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AssetsPaths.appLogo,
      height: height,
      width: width,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      color: Theme.of(context).colorScheme.primary,
      scale: scale,
    );
  }
}
