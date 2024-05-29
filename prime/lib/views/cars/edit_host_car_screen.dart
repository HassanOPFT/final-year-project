import 'package:flutter/material.dart';

import '../../models/car.dart';

class EditHostCarScreen extends StatelessWidget {
  final Car car;
  const EditHostCarScreen({
    super.key,
    required this.car,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Car'),
      ),
      body: const Center(
        child: Text('Edit Car'),
      ),
    );
  }
}
