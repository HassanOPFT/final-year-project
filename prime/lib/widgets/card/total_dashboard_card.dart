import 'package:flutter/material.dart';

class TotalDashboardCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;
  final Color backgroundColor;
  final Color iconColor;
  final Color valueColor;
  final Color titleColor;
  final double aspectRatio;

  const TotalDashboardCard({
    super.key,
    required this.icon,
    required this.value,
    required this.title,
    required this.backgroundColor,
    required this.iconColor,
    required this.valueColor,
    required this.titleColor,
    required this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 180.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: iconColor,
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
              const Spacer(),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: titleColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
