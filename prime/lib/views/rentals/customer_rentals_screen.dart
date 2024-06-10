import 'package:flutter/material.dart';

import '../../widgets/car_rentals_history_tab_body.dart';
import '../../widgets/navigation_bar/customer_navigation_bar.dart';
import '../../widgets/ongoing_and_upcoming_car_rentals_tab_body.dart';

class CustomerRentalsScreen extends StatefulWidget {
  const CustomerRentalsScreen({super.key});

  @override
  State<CustomerRentalsScreen> createState() => _CustomerRentalsScreenState();
}

class _CustomerRentalsScreenState extends State<CustomerRentalsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rentals'),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Ongoing & Upcoming',
                icon: Icon(Icons.schedule_rounded),
              ),
              Tab(
                text: 'History',
                icon: Icon(Icons.history_rounded),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OngoingAndUpcomingCarRentalsTabBody(),
            CarRentalsHistoryTabBody(),
          ],
        ),
        bottomNavigationBar: const CustomerNavigationBar(currentIndex: 1),
      ),
    );
  }
}
