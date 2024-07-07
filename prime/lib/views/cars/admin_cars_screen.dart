import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/car.dart';
import '../../providers/car_provider.dart';
import '../../providers/search_cars_provider.dart';
import '../../widgets/card/admin_car_card.dart';
import '../../widgets/custom_progress_indicator.dart';
import '../../widgets/no_data_found.dart';
import '../../widgets/navigation_bar/admin_navigation_bar.dart';

class AdminCarsScreen extends StatefulWidget {
  const AdminCarsScreen({super.key});

  @override
  State<AdminCarsScreen> createState() => _AdminCarsScreenState();
}

class _AdminCarsScreenState extends State<AdminCarsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cars'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 100));
          setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
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

                // Use a post frame callback to update the provider after the current build frame
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Provider.of<SearchCarsProvider>(
                    context,
                    listen: false,
                  ).setCarsList(carsList);
                });

                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      title: Consumer<SearchCarsProvider>(
                        builder: (context, searchProvider, _) {
                          return SearchBar(
                            hintText: 'Search Cars',
                            leading: const Icon(Icons.search_rounded),
                            trailing: [
                              if (_searchController.text.isNotEmpty)
                                IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    searchProvider.clearFilters();
                                  },
                                  icon: const Icon(Icons.clear_rounded),
                                )
                            ],
                            controller: _searchController,
                            onChanged: searchProvider.filterCars,
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                              const EdgeInsets.fromLTRB(20.0, 0.0, 10.0, 0.0),
                            ),
                          );
                        },
                      ),
                      toolbarHeight: 80.0,
                    ),
                    Consumer<SearchCarsProvider>(
                      builder: (context, searchProvider, _) {
                        final carsList = searchProvider.isSearchFilterActive
                            ? searchProvider.filteredCars
                            : searchProvider.carsList;

                        if (carsList.isEmpty) {
                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return const NoDataFound(
                                  title: 'No Results Found!',
                                  subTitle:
                                      'There are no cars available matching your search criteria. Please try again with different key words.',
                                );
                              },
                              childCount: 1,
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final car = carsList[index];
                              return AdminCarCard(car: car);
                            },
                            childCount: carsList.length,
                          ),
                        );
                      },
                    ),
                  ],
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
      ),
      bottomNavigationBar: const AdminNavigationBar(currentIndex: 2),
    );
  }
}
