import 'package:flutter/material.dart';
import 'package:prime/widgets/app_logo.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppLogo(height: 240.0),
            CustomProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
