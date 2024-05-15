import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/verification_document.dart';
import '../../../utils/navigate_with_animation.dart';
import '../../views/home/verification_document_details_screen.dart';

class VerificationDocumentTile extends StatelessWidget {
  final VerificationDocument verificationDocument;

  const VerificationDocumentTile({
    super.key,
    required this.verificationDocument,
  });

  @override
  Widget build(BuildContext context) {
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
          verificationDocument.documentType?.getDocumentTypeString() ?? 'N/A',
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Expiry Date: ${verificationDocument.expiryDate != null ? DateFormat.yMMMMd().format(verificationDocument.expiryDate as DateTime) : 'N/A'}\nRef No: ${verificationDocument.referenceNumber ?? 'N/A'}',
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_right_rounded,
          size: 30.0,
        ),
        onTap: () => animatedPushNavigation(
          context: context,
          screen: VerificationDocumentDetailsScreen(
            verificationDocument: verificationDocument,
          ),
        ),
      ),
    );
  }
}
