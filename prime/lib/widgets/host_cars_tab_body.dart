import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/car.dart';
import '../providers/car_provider.dart';
import '../services/firebase/firebase_auth_service.dart';
import 'card/host_car_card.dart';
import 'custom_progress_indicator.dart';
import 'floating_action_button/add_car_floating_action_button.dart';
import 'no_data_found.dart';

class HostCarsTabBody extends StatelessWidget {
  const HostCarsTabBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final firebaseAuthService = FirebaseAuthService();
    final carProvider = Provider.of<CarProvider>(context);
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: FutureBuilder<List<Car>>(
            future: carProvider.getCarsByHostId(
              firebaseAuthService.currentUser?.uid ?? '',
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CustomProgressIndicator();
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Error loading cars. Please try again later.'),
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final carsList = snapshot.data!
                    .where((car) => car.status != CarStatus.deletedByHost)
                    .toList();
                if (carsList.isNotEmpty) {
                  return ListView.builder(
                    itemCount: carsList.length,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 80.0,
                    ),
                    itemBuilder: (context, index) {
                      final car = carsList[index];
                      return HostCarCard(car: car);
                    },
                  );
                } else {
                  return const NoDataFound(
                    title: 'No Cars Found!',
                    subTitle:
                        'Add your car if you want to rent it to customers and become a host now!',
                  );
                }
              } else {
                return const NoDataFound(
                  title: 'No Cars Found!',
                  subTitle:
                      'Add your car if you want to rent it to customers and become a host now!',
                );
              }
            },
          ),
        ),
        const Positioned(
            bottom: 16.0,
            right: 16.0,
            child: AddCarFloatingButton(),
          ),
      ],
    );
  }
}
