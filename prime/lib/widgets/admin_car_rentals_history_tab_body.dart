import 'package:flutter/material.dart';
import 'package:prime/models/user.dart';
import 'package:prime/widgets/tiles/car_rental_card.dart';
import 'package:provider/provider.dart';

import '../models/car_rental.dart';
import '../providers/car_provider.dart';
import '../providers/car_rental_provider.dart';
import '../providers/search_rentals_provider.dart';
import 'custom_progress_indicator.dart';
import 'no_data_found.dart';

class AdminCarRentalsHistoryTabBody extends StatefulWidget {
  const AdminCarRentalsHistoryTabBody({super.key});

  @override
  State<AdminCarRentalsHistoryTabBody> createState() =>
      _AdminCarRentalsHistoryTabBodyState();
}

class _AdminCarRentalsHistoryTabBodyState
    extends State<AdminCarRentalsHistoryTabBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchRentalsHistory(
    BuildContext context,
  ) async {
    final carProvider = Provider.of<CarProvider>(context, listen: false);
    final carRentalProvider =
        Provider.of<CarRentalProvider>(context, listen: false);
    final rentalsHistoryWithCars = <Map<String, dynamic>>[];

    final carRentals = await carRentalProvider.getCarRentalsByStatuses(
      [
        CarRentalStatus.adminConfirmedRefund,
        CarRentalStatus.adminConfirmedPayout,
      ],
    );

    for (var carRental in carRentals) {
      if (carRental.carId != null) {
        final car = await carProvider.getCarById(carRental.carId!);
        rentalsHistoryWithCars.add({
          'car': car,
          'rental': carRental,
        });
      }
    }

    return rentalsHistoryWithCars;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchRentalsHistory(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const NoDataFound(
                title: 'Nothing Found',
                subTitle: 'No rental history found.',
              );
            } else {
              final rentalsHistoryWithCars = snapshot.data!;

              // Prevent infinite rebuilds by checking if the list has changed
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!Provider.of<SearchRentalsProvider>(context, listen: false)
                    .rentalsListEquals(rentalsHistoryWithCars)) {
                  Provider.of<SearchRentalsProvider>(context, listen: false)
                      .setRentalsList(rentalsHistoryWithCars);
                }
              });

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    toolbarHeight: 80.0,
                    title: Consumer<SearchRentalsProvider>(
                      builder: (context, searchProvider, _) {
                        return SearchBar(
                          hintText: 'Search Rentals',
                          leading: const Icon(Icons.search_rounded),
                          trailing: [
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  searchProvider.clearFilters();
                                },
                                icon: const Icon(Icons.clear_rounded),
                              ),
                          ],
                          controller: _searchController,
                          onChanged: searchProvider.filterRentals,
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.fromLTRB(20.0, 0.0, 10.0, 0.0),
                          ),
                        );
                      },
                    ),
                  ),
                  Consumer<SearchRentalsProvider>(
                    builder: (_, searchRentalsProvider, __) {
                      final childCount =
                          searchRentalsProvider.isSearchFilterActive
                              ? searchRentalsProvider.filteredRentals.length
                              : searchRentalsProvider.rentalsList.length;
                      if (childCount <= 0) {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return const NoDataFound(
                                title: 'No Results Found!',
                                subTitle:
                                    'There are no rentals matching your search criteria. Please try again with different keywords.',
                              );
                            },
                            childCount: 1,
                          ),
                        );
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final rentalWithCar = searchRentalsProvider
                                    .isSearchFilterActive
                                ? searchRentalsProvider.filteredRentals[index]
                                : searchRentalsProvider.rentalsList[index];

                            return CarRentalCard(
                              carRental: rentalWithCar['rental'],
                              car: rentalWithCar['car'],
                              userRole: UserRole.primaryAdmin,
                            );
                          },
                          childCount: searchRentalsProvider.isSearchFilterActive
                              ? searchRentalsProvider.filteredRentals.length
                              : searchRentalsProvider.rentalsList.length,
                        ),
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:prime/models/user.dart';
// import 'package:prime/widgets/tiles/car_rental_card.dart';
// import 'package:provider/provider.dart';

// import '../models/car_rental.dart';
// import '../providers/car_provider.dart';
// import '../providers/car_rental_provider.dart';
// import 'custom_progress_indicator.dart';
// import 'no_data_found.dart';

// class AdminCarRentalsHistoryTabBody extends StatelessWidget {
//   const AdminCarRentalsHistoryTabBody({super.key});

//   Future<List<Map<String, dynamic>>> _fetchRentalsHistory(
//       BuildContext context) async {
//     final carProvider = Provider.of<CarProvider>(context, listen: false);
//     final carRentalProvider =
//         Provider.of<CarRentalProvider>(context, listen: false);
//     final rentalsHistoryWithCars = <Map<String, dynamic>>[];

//     final carRentals = await carRentalProvider.getCarRentalsByStatuses(
//       [
//         CarRentalStatus.customerCancelled,
//         CarRentalStatus.hostCancelled,
//         CarRentalStatus.hostConfirmedReturn,
//         CarRentalStatus.adminConfirmedRefund,
//         CarRentalStatus.adminConfirmedPayout,
//       ],
//     );

//     for (var carRental in carRentals) {
//       if (carRental.carId != null) {
//         final car = await carProvider.getCarById(carRental.carId!);
//         rentalsHistoryWithCars.add({
//           'car': car,
//           'rental': carRental,
//         });
//       }
//     }

//     return rentalsHistoryWithCars;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(5.0),
//       child: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _fetchRentalsHistory(context),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const CustomProgressIndicator();
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const NoDataFound(
//               title: 'Nothing Found',
//               subTitle: 'No rental history found.',
//             );
//           } else {
//             final rentalsHistoryWithCars = snapshot.data!;
//             return ListView.builder(
//               itemCount: rentalsHistoryWithCars.length,
//               itemBuilder: (context, index) {
//                 final rentalWithCar = rentalsHistoryWithCars[index];
//                 return CarRentalCard(
//                   carRental: rentalWithCar['rental'],
//                   car: rentalWithCar['car'],
//                   userRole: UserRole.primaryAdmin,
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }
