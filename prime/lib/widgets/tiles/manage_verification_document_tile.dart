import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/verification_document.dart';
import '../../../utils/navigate_with_animation.dart';
import '../../providers/verification_document_provider.dart';
import '../../views/home/verification_document_details_screen.dart';
import '../verification_document_status_indicator.dart';

class AdminVerificationDocumentTile extends StatelessWidget {
  final String verificationDocumentId;

  const AdminVerificationDocumentTile({
    super.key,
    required this.verificationDocumentId,
  });

  @override
  Widget build(BuildContext context) {
    final verificationDocumentProvider =
        Provider.of<VerificationDocumentProvider>(context);

    return FutureBuilder<VerificationDocument?>(
      future: verificationDocumentProvider.getVerificationDocumentById(
        verificationDocumentId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data != null) {
          final verificationDocument = snapshot.data!;
          var leadingIcon = Icons.document_scanner_rounded;
          if (verificationDocument.documentType ==
              VerificationDocumentType.identity) {
            leadingIcon = Icons.person;
          } else if (verificationDocument.documentType ==
              VerificationDocumentType.drivingLicense) {
            leadingIcon = Icons.document_scanner_rounded;
          }

          return Card(
            child: ListTile(
              leading: Icon(
                leadingIcon,
                size: 30.0,
              ),
              title: Text(
                verificationDocument.documentType?.getDocumentTypeString() ??
                    'N/A',
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VerificationDocumentStatusIndicator(
                    verificationDocumentStatus: verificationDocument.status
                        as VerificationDocumentStatus,
                  ),
                  Text(
                    'Expires on ${verificationDocument.expiryDate != null ? DateFormat.yMMMMd().format(verificationDocument.expiryDate as DateTime) : 'N/A'}',
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              trailing: const Icon(
                Icons.keyboard_arrow_right_rounded,
                size: 30.0,
              ),
              onTap: () => animatedPushNavigation(
                context: context,
                screen: VerificationDocumentDetailsScreen(
                  verificationDocumentId: verificationDocument.id ?? '',
                ),
              ),
            ),
          );
        } else {
          return const Center(child: Text('No verification document found'));
        }
      },
    );
  }
}
