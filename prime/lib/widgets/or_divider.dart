import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildHorizontalLine(context),
        const Text('or'),
        _buildHorizontalLine(context),
      ],
    );
  }

  Expanded _buildHorizontalLine(context) {
    return Expanded(
      child: Divider(
        color: Theme.of(context).dividerColor,
        thickness: 1,
        indent: 10,
        endIndent: 10,
      ),
    );
  }
}
