import 'package:flutter/material.dart';

import '../../models/verification_document.dart';

class EditVerificationDocumentBottomSheet extends StatelessWidget {
  final Function updateVerificationDocument;
  final Function deleteVerificationDocument;
  final Function approveVerificationDocument;
  final Function rejectVerificationDocument;
  final Function haltVerificationDocument;
  final Function requestUnhaltVerificationDocument;
  final Function unhaltVerificationDocument;
  final bool isAdmin;
  final VerificationDocumentStatus documentStatus;
  final VerificationDocument verificationDocument;

  const EditVerificationDocumentBottomSheet({
    super.key,
    required this.updateVerificationDocument,
    required this.deleteVerificationDocument,
    required this.approveVerificationDocument,
    required this.rejectVerificationDocument,
    required this.haltVerificationDocument,
    required this.requestUnhaltVerificationDocument,
    required this.unhaltVerificationDocument,
    required this.isAdmin,
    required this.documentStatus,
    required this.verificationDocument,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Edit Document',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5.0),
          const Divider(),
          const SizedBox(height: 15.0),
          if (!isAdmin) ...[
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                updateVerificationDocument(verificationDocument);
              },
              icon: const Icon(Icons.edit),
              label: const Text(
                'Update Document',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
          if (isAdmin) ...[
            if (documentStatus == VerificationDocumentStatus.pendingApproval ||
                documentStatus == VerificationDocumentStatus.updated ||
                documentStatus == VerificationDocumentStatus.rejected) ...[
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  approveVerificationDocument(verificationDocument);
                },
                icon: const Icon(
                  Icons.check_circle_rounded,
                ),
                label: const Text(
                  'Approve Document',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
              if (documentStatus != VerificationDocumentStatus.rejected)
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    rejectVerificationDocument(verificationDocument);
                  },
                  icon: const Icon(
                    Icons.cancel_rounded,
                  ),
                  label: const Text(
                    'Reject Document',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
            ],
            if (documentStatus != VerificationDocumentStatus.halted &&
                documentStatus != VerificationDocumentStatus.unHaltRequested &&
                documentStatus !=
                    VerificationDocumentStatus.deletedByCustomer) ...[
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  haltVerificationDocument(verificationDocument);
                },
                icon: const Icon(
                  Icons.pause_rounded,
                ),
                label: const Text(
                  'Halt Document',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
            ],
            if (documentStatus == VerificationDocumentStatus.unHaltRequested ||
                documentStatus == VerificationDocumentStatus.halted) ...[
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  unhaltVerificationDocument(verificationDocument);
                },
                icon: const Icon(
                  Icons.play_circle_filled_rounded,
                ),
                label: const Text(
                  'Unhalt Document',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
            ],
          ],
          if (!isAdmin &&
              documentStatus == VerificationDocumentStatus.halted) ...[
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                requestUnhaltVerificationDocument(verificationDocument);
              },
              icon: const Icon(
                Icons.play_circle_filled_rounded,
              ),
              label: const Text(
                'Request Unhalt Document',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              deleteVerificationDocument(verificationDocument);
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
            ),
            label: const Text(
              'Delete Document',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
