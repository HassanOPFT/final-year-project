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

class AdminActiveCarRentalsTabBody extends StatefulWidget {
  const AdminActiveCarRentalsTabBody({super.key});

  @override
  State<AdminActiveCarRentalsTabBody> createState() =>
      _AdminActiveCarRentalsTabBodyState();
}

class _AdminActiveCarRentalsTabBodyState
    extends State<AdminActiveCarRentalsTabBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchActiveRentals(
      BuildContext context) async {
    final carProvider = Provider.of<CarProvider>(context, listen: false);
    final carRentalProvider =
        Provider.of<CarRentalProvider>(context, listen: false);
    final activeRentalsWithCars = <Map<String, dynamic>>[];

    final carRentals = await carRentalProvider.getCarRentalsByStatuses([
      CarRentalStatus.rentedByCustomer,
      CarRentalStatus.pickedUpByCustomer,
      CarRentalStatus.hostReportedIssue,
      CarRentalStatus.hostConfirmedPickup,
      CarRentalStatus.customerReturnedCar,
      CarRentalStatus.customerReportedIssue,
      CarRentalStatus.customerExtendedRental,
      CarRentalStatus.customerCancelled,
      CarRentalStatus.hostCancelled,
      CarRentalStatus.hostConfirmedReturn,
    ]);

    for (var carRental in carRentals) {
      if (carRental.carId != null) {
        final car = await carProvider.getCarById(carRental.carId!);
        activeRentalsWithCars.add({
          'car': car,
          'rental': carRental,
        });
      }
    }

    return activeRentalsWithCars;
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
          future: _fetchActiveRentals(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const NoDataFound(
                title: 'Nothing Found',
                subTitle: 'No active rentals found.',
              );
            } else {
              final activeRentalsWithCars = snapshot.data!;

              // Prevent infinite rebuilds by checking if the list has changed
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!Provider.of<SearchRentalsProvider>(context, listen: false)
                    .rentalsListEquals(activeRentalsWithCars)) {
                  Provider.of<SearchRentalsProvider>(context, listen: false)
                      .setRentalsList(activeRentalsWithCars);
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
                                    'There are no active rentals matching your search criteria. Please try again with different key words.',
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
