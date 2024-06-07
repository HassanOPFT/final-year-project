import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/car.dart';
import '../../providers/car_provider.dart';
import '../../services/firebase/firebase_auth_service.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/card/customer_car_card.dart';
import '../../widgets/custom_progress_indicator.dart';
import '../../widgets/navigation_bar/customer_navigation_bar.dart';
import '../../widgets/no_data_found.dart';

class CustomerExploreScreen extends StatelessWidget {
  const CustomerExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseAuthService = FirebaseAuthService();
    final carProvider = Provider.of<CarProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const AppLogo(height: 120),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: FutureBuilder<List<Car>>(
          future: carProvider.getCarsByStatusAndUserId(
            carStatusList: [
              CarStatus.approved.name,
            ],
            currentUserId: firebaseAuthService.currentUser?.uid ?? '',
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomProgressIndicator();
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Error loading cars. Please try again later.'),
              );
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final carsList = snapshot.data!;
              return ListView.builder(
                itemCount: carsList.length,
                itemBuilder: (context, index) {
                  final car = carsList[index];
                  return CustomerCarCard(car: car);
                },
              );
            } else {
              return const NoDataFound(
                title: 'No Cars Found!',
                subTitle:
                    'There are no cars available at the moment. please check again later!',
              );
            }
          },
        ),
      ),
      bottomNavigationBar: const CustomerNavigationBar(currentIndex: 0),
    );
  }
}
