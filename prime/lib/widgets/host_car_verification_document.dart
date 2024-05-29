import 'package:flutter/material.dart';
import 'package:prime/widgets/tiles/verification_document_tile.dart';
import '../utils/navigate_with_animation.dart';
import 'custom_progress_indicator.dart';
import '../providers/verification_document_provider.dart';
import '../models/verification_document.dart';
import '../views/profile/upload_verification_document_screen.dart';

class HostCarVerificationDocument extends StatelessWidget {
  final VerificationDocumentType verificationDocumentType;
  final String verificationDocumentId;
  final VerificationDocumentProvider verificationDocumentProvider;
  final String linkedObjectId;
  final String uploadButtonText;

  const HostCarVerificationDocument({
    super.key,
    required this.verificationDocumentType,
    required this.verificationDocumentId,
    required this.verificationDocumentProvider,
    required this.linkedObjectId,
    required this.uploadButtonText,
  });

  Widget _buildNoDataFound(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const Text(
            'It seems you have not uploaded any document yet',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20.0),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () => animatedPushNavigation(
                context: context,
                screen: UploadVerificationDocumentScreen(
                  linkedObjectId: linkedObjectId,
                  verificationDocumentType: verificationDocumentType,
                ),
              ),
              child: Text(
                uploadButtonText,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (verificationDocumentId.isEmpty) {
      return _buildNoDataFound(context);
    }

    return FutureBuilder<VerificationDocument?>(
      future: verificationDocumentProvider.getVerificationDocumentById(
        verificationDocumentId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error while fetching document');
        } else if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.status !=
                VerificationDocumentStatus.deletedByCustomer) {
          final document = snapshot.data!;
          return VerificationDocumentTile(
            verificationDocumentId: document.id ?? '',
          );
        } else {
          return _buildNoDataFound(context);
        }
      },
    );
  }
}
