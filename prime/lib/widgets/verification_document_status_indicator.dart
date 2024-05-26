import 'package:flutter/material.dart';

import '../models/verification_document.dart';

class VerificationDocumentStatusIndicator extends StatelessWidget {
  final VerificationDocumentStatus verificationDocumentStatus;

  const VerificationDocumentStatusIndicator({
    super.key,
    required this.verificationDocumentStatus,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (verificationDocumentStatus) {
      case VerificationDocumentStatus.uploaded:
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade900;
        break;
      case VerificationDocumentStatus.pendingApproval:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade900;
        break;
      case VerificationDocumentStatus.approved:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade900;
        break;
      case VerificationDocumentStatus.rejected:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade900;
        break;
      case VerificationDocumentStatus.updated:
        backgroundColor = Colors.yellow.shade50;
        textColor = Colors.yellow.shade900;
        break;
      case VerificationDocumentStatus.halted:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade900;
        break;
      case VerificationDocumentStatus.unHaltRequested:
        backgroundColor = Colors.purple.shade50;
        textColor = Colors.purple.shade900;
        break;
      case VerificationDocumentStatus.deletedByCustomer:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade900;
        break;
      case VerificationDocumentStatus.deletedByAdmin:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade900;
        break;
      default:
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade900;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Text(
        verificationDocumentStatus.getStatusString(),
        style: TextStyle(
          fontSize: 16.0,
          color: textColor,
        ),
      ),
    );
  }
}
