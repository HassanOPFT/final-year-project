import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/verification_document.dart';
import '../providers/verification_document_provider.dart';
import '../services/firebase/firebase_auth_service.dart';
import '../utils/navigate_with_animation.dart';
import '../views/profile/upload_verification_document_screen.dart';
import 'custom_progress_indicator.dart';
import 'no_data_found.dart';
import 'tiles/verification_document_tile.dart';

class DrivingLicenseTabBody extends StatelessWidget {
  const DrivingLicenseTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    final verificationDocumentProvider =
        Provider.of<VerificationDocumentProvider>(context);
    final authService = FirebaseAuthService();
    final userId = authService.currentUser?.uid ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      child: FutureBuilder<VerificationDocument?>(
        future:
            verificationDocumentProvider.getVerificationDocumentByDocumentType(
          userId,
          VerificationDocumentType.drivingLicense,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Error while fetching driving license');
          } else if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.status !=
                  VerificationDocumentStatus.deletedByCustomer) {
            final document = snapshot.data!;
            return Column(
              children: [
                VerificationDocumentTile(
                  verificationDocumentId: document.id ?? '',
                ),
              ],
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Flexible(
                  flex: 6,
                  child: NoDataFound(
                    title: 'No Driving License Found',
                    subTitle:
                        'It seems you have not uploaded any driving license yet.',
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: () => animatedPushNavigation(
                        context: context,
                        screen: UploadVerificationDocumentScreen(
                          linkedObjectId: userId,
                          verificationDocumentType:
                              VerificationDocumentType.drivingLicense,
                        ),
                      ),
                      child: const Text(
                        'Upload Driving License',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
