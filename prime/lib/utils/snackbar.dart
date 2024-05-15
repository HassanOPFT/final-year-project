import 'package:flutter/material.dart';

void buildSuccessSnackbar({
  required BuildContext context,
  required String message,
}) {
  Color backgroundColor = Colors.green.shade100;
  Color textColor = Colors.green.shade900;
  const iconData = Icons.check_circle_outline;

  _buildCustomSnackbar(
    context: context,
    title: 'Success!',
    message: message,
    iconData: iconData,
    backgroundColor: backgroundColor,
    textColor: textColor,
  );
}

void buildFailureSnackbar({
  required BuildContext context,
  required String message,
}) {
  Color backgroundColor = Colors.red.shade100;
  Color textColor = Colors.red.shade900;
  const iconData = Icons.error_outline;

  _buildCustomSnackbar(
    context: context,
    title: 'Error!',
    message: message,
    iconData: iconData,
    backgroundColor: backgroundColor,
    textColor: textColor,
  );
}

void buildAlertSnackbar({
  required BuildContext context,
  required String message,
}) {
  Color backgroundColor = Colors.orange.shade50;
  Color textColor = Colors.orange.shade900;
  const iconData = Icons.warning_amber_outlined;

  _buildCustomSnackbar(
    context: context,
    title: 'Alert!',
    message: message,
    iconData: iconData,
    backgroundColor: backgroundColor,
    textColor: textColor,
  );
}

void buildInfoSnackbar({
  required BuildContext context,
  required String message,
}) {
  Color backgroundColor = Colors.blue.shade50;
  Color textColor = Colors.blue.shade900;
  const iconData = Icons.info_outline;

  _buildCustomSnackbar(
    context: context,
    title: 'Information!',
    message: message,
    iconData: iconData,
    backgroundColor: backgroundColor,
    textColor: textColor,
  );
}

void _buildCustomSnackbar({
  required BuildContext context,
  required String title,
  required String message,
  required IconData iconData,
  required Color backgroundColor,
  required Color textColor,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      padding: const EdgeInsets.all(0.0),
      content: ListTile(
        leading: Icon(
          iconData,
          color: textColor,
          size: 30.0,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: textColor,
          ),
        ),
        subtitle: Text(
          message,
          style: TextStyle(
            fontSize: 16.0,
            color: textColor,
          ),
        ),
      ),
    ),
  );
}
