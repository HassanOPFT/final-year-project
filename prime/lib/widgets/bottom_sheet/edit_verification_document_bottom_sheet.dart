import 'package:flutter/material.dart';

class EditVerificationDocumentBottomSheet extends StatelessWidget {
  final Function updateVerificationDocument;
  final Function deleteVerificationDocument;

  const EditVerificationDocumentBottomSheet({
    super.key,
    required this.updateVerificationDocument,
    required this.deleteVerificationDocument,
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
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              updateVerificationDocument();
            },
            icon: const Icon(Icons.edit),
            label: const Text(
              'Update Document',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              deleteVerificationDocument();
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
