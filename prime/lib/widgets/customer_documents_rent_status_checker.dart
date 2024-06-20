import 'package:flutter/material.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';

class CustomerDocumentsRentStatusChecker extends StatelessWidget {
  final Future<bool> Function() hasApprovedIdentityDocument;
  final Future<bool> Function() hasApprovedDrivingLicenseDocument;
  final Future<bool> Function() hasPhoneNumber;

  const CustomerDocumentsRentStatusChecker({
    super.key,
    required this.hasApprovedIdentityDocument,
    required this.hasApprovedDrivingLicenseDocument,
    required this.hasPhoneNumber,
  });

  Future<List<bool>> _checkDocuments() async {
    return Future.wait([
      hasApprovedIdentityDocument(),
      hasApprovedDrivingLicenseDocument(),
      hasPhoneNumber(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<bool>>(
      future: _checkDocuments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final missingDocuments = <String>[];

          if (!snapshot.data![0]) {
            missingDocuments.add('approved identity document.');
          }
          if (!snapshot.data![1]) {
            missingDocuments.add('approved driving license document.');
          }
          if (!snapshot.data![2]) {
            missingDocuments.add('phone number under your profile.');
          }

          if (missingDocuments.isEmpty) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              leading: Icon(
                Icons.warning_amber_outlined,
                color: Colors.orange.shade900,
                size: 32.0,
              ),
              title: Text(
                'You need the following to rent a car:',
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...missingDocuments.map(
                    (doc) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5.0,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: Colors.orange.shade900,
                            size: 8.0,
                          ),
                          const SizedBox(width: 15.0),
                          Expanded(
                            child: Text(
                              doc,
                              style: TextStyle(
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
