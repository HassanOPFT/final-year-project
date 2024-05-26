import 'package:flutter/material.dart';

class SectionDivider extends StatelessWidget {
  final String sectionTitle;
  const SectionDivider({
    super.key,
    required this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    Expanded buildCustomDivider() {
      return Expanded(
        child: Divider(
          color: Theme.of(context).dividerColor,
          thickness: 1,
          indent: 10,
          endIndent: 10,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildCustomDivider(),
        Text(
          sectionTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        buildCustomDivider(),
      ],
    );
  }
}
