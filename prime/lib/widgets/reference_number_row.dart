import 'package:flutter/material.dart';

import 'copy_text.dart';

class ReferenceNumberRow extends StatelessWidget {
  final String? referenceNumber;
  const ReferenceNumberRow({
    super.key,
    required this.referenceNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Reference No',
          style: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 16.0,
          ),
        ),
        CopyText(
          text: referenceNumber ?? 'N/A',
          fontSize: 16.0,
        )
      ],
    );
  }
}
