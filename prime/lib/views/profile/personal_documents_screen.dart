import 'package:flutter/material.dart';

import '../../widgets/driving_license_tab_body.dart';
import '../../widgets/identity_tab_body.dart';

class PersonalDocumentsScreen extends StatelessWidget {
  const PersonalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Personal Documents'),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Identity',
                icon: Icon(Icons.person),
              ),
              Tab(
                text: 'Driving License',
                icon: Icon(Icons.document_scanner_rounded),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            IdentityTabBody(),
            DrivingLicenseTabBody(),
          ],
        ),
      ),
    );
  }
}
