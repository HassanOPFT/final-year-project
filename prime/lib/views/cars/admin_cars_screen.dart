import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/car.dart';
import '../../providers/car_provider.dart';
import '../../widgets/card/admin_car_card.dart';
import '../../widgets/custom_progress_indicator.dart';
import '../../widgets/no_data_found.dart';
import '../../widgets/navigation_bar/admin_navigation_bar.dart';

class AdminCarsScreen extends StatelessWidget {
  const AdminCarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cars'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: FutureBuilder<List<Car>>(
          future: carProvider.getAllCars(),
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
                  return AdminCarCard(car: car);
                },
              );
            } else {
              return const NoDataFound(
                title: 'No Cars Found!',
                subTitle: 'There are no cars available at the moment.',
              );
            }
          },
        ),
      ),
      bottomNavigationBar: const AdminNavigationBar(currentIndex: 2),
    );
  }
}
