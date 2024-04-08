import 'package:flutter/material.dart';

import '../../utils/navigation/navigate_with_animation.dart';
import '../../views/profile/customer_profile_screen.dart';
import '../../views/home/customer_explore_screen.dart';
import '../../views/rentals/customer_rentals_screen.dart';
import '../../views/host/host_screen.dart';

final List<Widget> customerScreens = [
  const CustomerExploreScreen(),
  const CustomerRentalsScreen(),
  const HostScreen(),
  const CustomerProfileScreen(),
];

class CustomerNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomerNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => navigateWithAnimation(
        context,
        customerScreens[index],
      ),
      destinations: [
        _buildNavigationDestination(
          icon: const Icon(Icons.explore_outlined),
          selectedIcon: const Icon(Icons.explore_rounded),
          label: 'Explore',
        ),
        _buildNavigationDestination(
          icon: const Icon(Icons.directions_car_outlined),
          selectedIcon: const Icon(Icons.directions_car_rounded),
          label: 'Rentals',
        ),
        _buildNavigationDestination(
          icon: const Icon(Icons.car_rental_outlined),
          selectedIcon: const Icon(Icons.car_rental_rounded),
          label: 'Host',
        ),
        _buildNavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }

  NavigationDestination _buildNavigationDestination({
    required Icon icon,
    required String label,
    required Icon selectedIcon,
  }) {
    return NavigationDestination(
      icon: icon,
      selectedIcon: selectedIcon,
      label: label,
    );
  }
}
