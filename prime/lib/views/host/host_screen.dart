import 'package:flutter/material.dart';
import '../../widgets/host_active_rentals_tab_body.dart';
import '../../widgets/host_cars_tab_body.dart';
import '../../widgets/host_rentals_history_tab_body.dart';
import '../../widgets/navigation_bar/customer_navigation_bar.dart';

class HostScreen extends StatelessWidget {
  const HostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Host'),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Cars',
                icon: Icon(Icons.car_rental_rounded),
              ),
              Tab(
                text: 'Active Rentals',
                icon: Icon(Icons.directions_car_rounded),
              ),
              Tab(
                text: 'Rentals History',
                icon: Icon(Icons.history_rounded),
              ),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: const TabBarView(
          children: [
            HostCarsTabBody(),
            HostActiveRentalsTabBody(),
            HostRentalsHistoryTabBody(),
          ],
        ),
        bottomNavigationBar: const CustomerNavigationBar(currentIndex: 2),
      ),
    );
  }
}
