import 'package:flutter/material.dart';

void _navigateWithAnimation({
  required BuildContext context,
  required Widget screen,
  bool replace = false,
  Map<String, dynamic>? arguments,
}) {
  final route = PageRouteBuilder(
    transitionsBuilder: _transitionBuilder,
    pageBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) {
      return screen;
    },
    settings: arguments != null ? RouteSettings(arguments: arguments) : null,
  );

  if (replace) {
    Navigator.pushReplacement(context, route);
  } else {
    Navigator.push(context, route);
  }
}

Widget _transitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  animation = CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOut,
  );
  return FadeTransition(
    opacity: animation,
    child: child,
  );
}

void animatedPushNavigation({
  required BuildContext context,
  required Widget screen,
  Map<String, dynamic>? arguments,
}) {
  _navigateWithAnimation(
    context: context,
    screen: screen,
    arguments: arguments,
  );
}

void animatedPushReplacementNavigation({
  required BuildContext context,
  required Widget screen,
  Map<String, dynamic>? arguments,
}) {
  _navigateWithAnimation(
    context: context,
    screen: screen,
    replace: true,
    arguments: arguments,
  );
}
