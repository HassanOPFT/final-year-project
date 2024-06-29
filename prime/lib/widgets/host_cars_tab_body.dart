import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/car.dart';
import '../providers/car_provider.dart';
import '../services/firebase/firebase_auth_service.dart';
import 'card/host_car_card.dart';
import 'card/revenue_dashboard_card.dart';
import 'custom_progress_indicator.dart';
import 'floating_action_button/add_car_floating_action_button.dart';
import 'no_data_found.dart';
import '../utils/finance_util.dart';

class HostCarsTabBody extends StatelessWidget {
  const HostCarsTabBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final firebaseAuthService = FirebaseAuthService();
    final carProvider = Provider.of<CarProvider>(context);
    final financeUtil = FinanceUtil();

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
                  return FutureBuilder<double>(
                    future: financeUtil.getTotalHostRevenueByHostId(
                      firebaseAuthService.currentUser?.uid ?? '',
                    ),
                    builder: (context, revenueSnapshot) {
                      if (revenueSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CustomProgressIndicator();
                      } else if (revenueSnapshot.hasError) {
                        return const Center(
                          child: Text(
                              'Error loading revenue. Please try again later.'),
                        );
                      } else {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 80.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 10.0),
                              RevenueDashboardCard(
                                icon: Icons.attach_money,
                                value:
                                    'RM${revenueSnapshot.data?.toStringAsFixed(2) ?? 0}',
                                title: 'Hosting Revenue',
                                backgroundColor: Colors.green.shade100,
                                iconColor: Colors.green.shade900,
                                valueColor: Colors.green.shade900,
                                titleColor: Colors.green.shade900,
                                aspectRatio: 0.5,
                              ),
                              const SizedBox(height: 5),
                              for (final car in carsList) HostCarCard(car: car),
                            ],
                          ),
                        );
                      }
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
