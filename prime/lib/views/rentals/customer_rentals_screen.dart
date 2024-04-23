import 'package:flutter/material.dart';

import '../../widgets/navigation_bar/customer_navigation_bar.dart';
import '../../widgets/user_image.dart';

class CustomerRentalsScreen extends StatefulWidget {
  const CustomerRentalsScreen({super.key});

  @override
  State<CustomerRentalsScreen> createState() => _CustomerRentalsScreenState();
}

class _CustomerRentalsScreenState extends State<CustomerRentalsScreen> {
  String _imageUrl = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rentals'),
      ),
      body: Center(
        // child: Text('Rentals'),
        child: UserImage(
          onFileChanged: (String imageUrl) {
            setState(() {
              _imageUrl = imageUrl;
            });
          },
        ),
      ),
      bottomNavigationBar: const CustomerNavigationBar(currentIndex: 1),
    );
  }
}
