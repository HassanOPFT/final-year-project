import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/verification_document.dart';
import '../providers/verification_document_provider.dart';
import 'tiles/manage_verification_document_tile.dart';

class UserVerificationDocuments extends StatelessWidget {
  final String userId;

  const UserVerificationDocuments({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final verificationDocumentProvider =
        Provider.of<VerificationDocumentProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verification Documents',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10.0),
        FutureBuilder<List<VerificationDocument>>(
          future: verificationDocumentProvider
              .getVerificationDocumentsByLinkedObjectId(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final verificationDocument = snapshot.data![index];
                  return AdminVerificationDocumentTile(
                    verificationDocumentId: verificationDocument.id ?? '',
                  );
                },
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20.0),
                    Icon(
                      Icons.description_outlined,
                      size: 60.0,
                      color: Theme.of(context).dividerColor,
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      'No verification documents found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      'There are no verification documents available for this user.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
