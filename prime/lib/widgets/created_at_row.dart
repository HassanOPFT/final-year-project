import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreatedAtRow extends StatelessWidget {
  final DateTime? createdAt;
  final String labelText;
  const CreatedAtRow({
    super.key,
    required this.labelText,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          labelText,
          style: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 16.0,
          ),
        ),
        Text(
          DateFormat.yMMMd().add_jm().format(createdAt ?? DateTime.now()),
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }
}
