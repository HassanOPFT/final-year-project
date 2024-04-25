import 'package:flutter/material.dart';

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
      onTap: () {},
    );
  }
}
