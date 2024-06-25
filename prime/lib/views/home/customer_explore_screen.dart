import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/car.dart';
import '../../providers/car_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/firebase/firebase_auth_service.dart';
import '../../utils/navigate_with_animation.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/card/customer_car_card.dart';
import '../../widgets/custom_progress_indicator.dart';
import '../../widgets/navigation_bar/customer_navigation_bar.dart';
import '../../widgets/no_data_found.dart';
import 'notification_screen.dart';

// TODO: location based listing of cars should be provided, nearest cars should be shown first
// TODO: add a search bar to search cars by name, model, etc.

class CustomerExploreScreen extends StatelessWidget {
  const CustomerExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseAuthService = FirebaseAuthService();
    final currentUserId = firebaseAuthService.currentUser?.uid ?? '';
    final carProvider = Provider.of<CarProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const AppLogo(height: 120.0),
        automaticallyImplyLeading: false,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () => animatedPushNavigation(
                  context: context,
                  screen: NotificationScreen(
                    userId: currentUserId,
                  ),
                ),
              ),
              Consumer<NotificationProvider>(
                builder: (_, notificationProvider, __) {
                  return FutureBuilder(
                    future: notificationProvider
                        .hasUnreadNotification(currentUserId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      } else if (snapshot.hasError) {
                        return const SizedBox();
                      } else if (snapshot.hasData) {
                        final hasUnread = snapshot.data as bool;

                        if (hasUnread) {
                          return Positioned(
                            top: 5.0,
                            right: 8.0,
                            child: Container(
                              width: 12.0,
                              height: 12.0,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      } else {
                        return const SizedBox();
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: StreamBuilder<List<Car>>(
          stream: carProvider.getCarsByStatusAndUserIdStream(
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
