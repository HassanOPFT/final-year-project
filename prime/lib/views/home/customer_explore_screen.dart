import 'package:flutter/material.dart';

import '../../utils/snackbar.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/navigation_bar/customer_navigation_bar.dart';

class CustomerExploreScreen extends StatelessWidget {
  const CustomerExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const AppLogo(height: 120),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Explore'),
            // ElevatedButton(
            //   onPressed: () {
            //     buildSuccessSnackbar(
            //       context: context,
            //       message: 'Success Snackbar',
            //     );
            //   },
            //   child: const Text('Show Success Snackbar'),
            // ),
            // const SizedBox(height: 16.0),
            // ElevatedButton(
            //   onPressed: () {
            //     buildFailureSnackbar(
            //       context: context,
            //       message: 'Failure Snackbar',
            //     );
            //   },
            //   child: const Text('Show Failure Snackbar'),
            // ),
            // const SizedBox(height: 16.0),
            // ElevatedButton(
            //   onPressed: () {
            //     buildWarningSnackbar(
            //       context: context,
            //       message: 'Warning Snackbar',
            //     );
            //   },
            //   child: const Text('Show Warning Snackbar'),
            // ),
            // const SizedBox(height: 16.0),
            // ElevatedButton(
            //   onPressed: () {
            //     buildInfoSnackbar(
            //       context: context,
            //       message: 'Info Snackbar',
            //     );
            //   },
            //   child: const Text('Show Info Snackbar'),
            // ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomerNavigationBar(currentIndex: 0),
    );
  }
}
