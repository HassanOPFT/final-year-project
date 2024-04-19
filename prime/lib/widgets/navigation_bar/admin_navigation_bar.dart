import 'package:flutter/material.dart';

import '../../utils/navigate_with_animation.dart';
import '../../views/admin/admin_users_screen.dart';
import '../../views/cars/admin_cars_screen.dart';
import '../../views/home/admin_dashboard_screen.dart';
import '../../views/profile/admin_profile_screen.dart';
import '../../views/rentals/admin_rentals_screen.dart';

final List<Widget> adminScreens = [
  const AdminDashboardScreen(),
  const AdminRentalsScreen(),
  const AdminCarsScreen(),
  const AdminUsersScreen(),
  const AdminProfileScreen(),
];

class AdminNavigationBar extends StatelessWidget {
  final int currentIndex;

  const AdminNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => animatedPushReplacementNavigation(
        context: context,
        screen: adminScreens[index],
      ),
      destinations: [
        _buildNavigationDestination(
          icon: const Icon(Icons.dashboard_outlined),
          selectedIcon: const Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        _buildNavigationDestination(
          icon: const Icon(Icons.directions_car_outlined),
          selectedIcon: const Icon(Icons.directions_car_rounded),
          label: 'Rentals',
        ),
        _buildNavigationDestination(
          icon: const Icon(Icons.car_rental_outlined),
          selectedIcon: const Icon(Icons.car_rental_rounded),
          label: 'Cars',
        ),
        _buildNavigationDestination(
          icon: const Icon(Icons.manage_accounts_outlined),
          selectedIcon: const Icon(Icons.manage_accounts_rounded),
          label: 'Users',
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
