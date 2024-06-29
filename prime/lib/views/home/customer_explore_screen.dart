// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/car.dart';
import '../../providers/car_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/search_cars_provider.dart';
import '../../services/firebase/firebase_auth_service.dart';
import '../../utils/navigate_with_animation.dart';
import '../../utils/snackbar.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/card/customer_car_card.dart';
import '../../widgets/custom_progress_indicator.dart';
import '../../widgets/navigation_bar/customer_navigation_bar.dart';
import '../../widgets/no_data_found.dart';
import 'notification_screen.dart';

class CustomerExploreScreen extends StatefulWidget {
  const CustomerExploreScreen({super.key});

  @override
  State<CustomerExploreScreen> createState() => _CustomerExploreScreenState();
}

class _CustomerExploreScreenState extends State<CustomerExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // _initLocationAndSortCars();
  }

  Future<void> _initLocationAndSortCars() async {
    final location = Location();
    final permissionStatus = await location.hasPermission();

    if (permissionStatus == PermissionStatus.denied ||
        permissionStatus == PermissionStatus.deniedForever) {
      await location.requestPermission();
    }

    if (permissionStatus == PermissionStatus.granted ||
        permissionStatus == PermissionStatus.grantedLimited) {
      try {
        final currentLocation = await location.getLocation();

        final initialLocation = LatLng(
          currentLocation.latitude ?? 0.0,
          currentLocation.longitude ?? 0.0,
        );

        final searchProvider = Provider.of<SearchCarsProvider>(
          context,
          listen: false,
        );
        await searchProvider.sortCarsByLocation(initialLocation);
      } catch (e) {
        buildFailureSnackbar(
          context: context,
          message: 'Error occurred while getting location. Please try again.',
        );
      }
    }
  }

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

              WidgetsBinding.instance.addPostFrameCallback((_) {
                Provider.of<SearchCarsProvider>(
                  context,
                  listen: false,
                ).setCarsList(carsList);
                _initLocationAndSortCars();
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
                    toolbarHeight: 90.0,
                  ),
                  Consumer<SearchCarsProvider>(
                    builder: (context, searchCarsProvider, child) {
                      if (!searchCarsProvider.isNearestFilterActive) {
                        return const SliverToBoxAdapter(
                          child: SizedBox(),
                        );
                      }

                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                          // child: FilterChip(
                          //   label: const Text('Nearest Available'),
                          //   selected: false,
                          //   onSelected: (bool value) async {
                          //     if (value == true) {
                          //       await _initLocationAndSortCars();
                          //     }
                          //   },
                          //   checkmarkColor: Colors.black,
                          //   selectedColor: Colors.green[100],
                          //   backgroundColor: Colors.green[50],
                          //   deleteIcon: const Icon(
                          //     Icons.clear_rounded,
                          //     color: Colors.black,
                          //   ),
                          //   onDeleted: () => searchCarsProvider.clearFilters(),
                          // ),
                          child: Text(
                            'Nearest Available',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Consumer<SearchCarsProvider>(
                    builder: (context, searchProvider, _) {
                      var carsToShow = searchProvider.isNearestFilterActive
                          ? searchProvider.nearestCars
                          : searchProvider.carsList;

                      if (searchProvider.isSearchFilterActive) {
                        carsToShow = searchProvider.filteredCars;
                      }

                      if (carsToShow.isEmpty) {
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
                            final car = carsToShow[index];
                            return CustomerCarCard(car: car);
                          },
                          childCount: carsToShow.length,
                        ),
                      );
                    },
                  ),
                ],
              );
            } else {
              return const NoDataFound(
                title: 'No Cars Found!',
                subTitle: 'No cars available at the moment.',
              );
            }
          },
        ),
      ),
      bottomNavigationBar: const CustomerNavigationBar(currentIndex: 0),
    );
  }
}
