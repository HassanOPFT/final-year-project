import 'package:flutter/material.dart';

class DialogUtils {
  static void showSuccessDialog({
    required BuildContext context,
    required String message,
  }) {
    _buildDialog(
      context: context,
      title: 'Success',
      message: message,
      icon: Icons.check_circle_outline,
      iconColor: Colors.green,
    );
  }

  static void showErrorDialog({
    required BuildContext context,
    required String message,
  }) {
    _buildDialog(
      context: context,
      title: 'Error',
      message: message,
      icon: Icons.error_outline,
      iconColor: Colors.red,
    );
  }

  static void _buildDialog({
    required BuildContext context,
    required String title,
    required String message,
    IconData? icon,
    Color? iconColor,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              if (icon != null)
                Icon(
                  icon,
                  color: iconColor,
                  size: 100.0,
                ),
              if (icon != null) const SizedBox(height: 20.0),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32.0,
                ),
              ),
              if (icon != null) const SizedBox(height: 10.0),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20.0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
