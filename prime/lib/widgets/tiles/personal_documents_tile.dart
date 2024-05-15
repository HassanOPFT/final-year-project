import 'package:flutter/material.dart';
import 'package:prime/utils/navigate_with_animation.dart';

import '../../views/profile/personal_documents_screen.dart';

class PersonalDocumentsTile extends StatelessWidget {
  const PersonalDocumentsTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.document_scanner_rounded),
      title: const Text(
        'Personal Documents',
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
      trailing: const Icon(Icons.keyboard_arrow_right_rounded),
      onTap: () => animatedPushNavigation(
        context: context,
        screen: const PersonalDocumentsScreen(),
      ),
    );
  }
}
