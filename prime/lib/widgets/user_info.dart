import 'package:flutter/material.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Hassan Mustafa',
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          '+1234567890',
          style: TextStyle(
            fontSize: 16.0,
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
