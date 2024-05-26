import 'package:flutter/material.dart';
import 'package:prime/widgets/tiles/verification_document_tile.dart';
import 'package:provider/provider.dart';

import '../services/firebase/firebase_auth_service.dart';
import '../utils/navigate_with_animation.dart';
import 'custom_progress_indicator.dart';
import '../providers/verification_document_provider.dart';
import '../models/verification_document.dart';
import '../views/profile/upload_verification_document_screen.dart';
import 'no_data_found.dart';

class IdentityTabBody extends StatelessWidget {
  const IdentityTabBody({super.key});

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
          VerificationDocumentType.identity,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Error while fetching identity document');
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
                    title: 'No Identity Document Found',
                    subTitle:
                        'It seems you have not uploaded any identity document yet.',
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
                              VerificationDocumentType.identity,
                        ),
                      ),
                      child: const Text(
                        'Upload Identity Document',
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
