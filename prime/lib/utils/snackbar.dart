import 'package:flutter/material.dart';

void buildSuccessSnackbar({
  required BuildContext context,
  required String message,
}) {
  const backgroundColor = Color.fromARGB(255, 232, 247, 242);
  const iconData = Icons.check_circle_outline;
  const textColor = Color.fromARGB(255, 38, 151, 109);

  _buildCustomSnackbar(
    context: context,
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
  const backgroundColor = Color.fromARGB(255, 255, 242, 242);
  const iconData = Icons.error_outline;
  const textColor = Color.fromARGB(255, 219, 5, 5);

  _buildCustomSnackbar(
    context: context,
    message: message,
    iconData: iconData,
    backgroundColor: backgroundColor,
    textColor: textColor,
  );
}

void buildWarningSnackbar({
  required BuildContext context,
  required String message,
}) {
  const backgroundColor = Color.fromARGB(255, 255, 244, 235);
  const iconData = Icons.warning_amber_outlined;
  const textColor = Color.fromARGB(255, 244, 171, 107);

  _buildCustomSnackbar(
    context: context,
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
  const backgroundColor = Color.fromRGBO(233, 245, 255, 1);

  const iconData = Icons.info_outline;
  const textColor = Color.fromRGBO(69, 130, 223, 1);

  _buildCustomSnackbar(
    context: context,
    message: message,
    iconData: iconData,
    backgroundColor: backgroundColor,
    textColor: textColor,
  );
}

void _buildCustomSnackbar({
  required BuildContext context,
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
      // elevation: 0,
      margin: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 15.0,
      ),
      padding: const EdgeInsets.all(18.0),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            color: textColor,
            size: 24.0,
          ),
          const SizedBox(width: 16.0),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16.0,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// void buildSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Theme.of(context).colorScheme.error,
//         behavior: SnackBarBehavior.floating,
//         elevation: 20,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//       ),
//     );
//   }