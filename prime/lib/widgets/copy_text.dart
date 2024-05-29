import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyText extends StatefulWidget {
  final String text;
  final double fontSize;

  const CopyText({super.key, required this.text, this.fontSize = 14.0});

  @override
  State<CopyText> createState() => _CopyTextWidgetState();
}

class _CopyTextWidgetState extends State<CopyText> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: widget.text));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copied to clipboard')),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.text,
            style: TextStyle(
              fontSize: widget.fontSize,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.copy),
        ],
      ),
    );
  }
}
