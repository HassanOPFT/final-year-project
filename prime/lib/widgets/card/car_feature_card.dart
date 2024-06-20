import 'package:flutter/material.dart';

class CarFeatureCard extends StatelessWidget {
  final dynamic featureIcon; // Can be IconData or Image.asset
  final String featureName;
  final String featureValue;

  const CarFeatureCard({
    super.key,
    required this.featureIcon,
    required this.featureName,
    required this.featureValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildFeatureIcon(context),
          const SizedBox(height: 5.0),
          Text(
            featureName,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          Text(
            featureValue,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(BuildContext context) {
    if (featureIcon is IconData) {
      return Icon(featureIcon);
    } else if (featureIcon is Image) {
      return featureIcon;
    } else {
      return const SizedBox.shrink();
    }
  }
}
