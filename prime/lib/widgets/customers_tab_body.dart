import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_users_provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../services/firebase/firebase_auth_service.dart';
import 'custom_progress_indicator.dart';
import 'no_data_found.dart';
import 'tiles/user_details_tile.dart';

class CustomersTabBody extends StatefulWidget {
  const CustomersTabBody({super.key});

  @override
  State<CustomersTabBody> createState() => _CustomersTabBodyState();
}

class _CustomersTabBodyState extends State<CustomersTabBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<User>> _fetchCustomers(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final firebaseAuthService = FirebaseAuthService();
    String currentUserId = firebaseAuthService.currentUser?.uid ?? '';

    return await userProvider.getUsers(
      usersRoles: [
        UserRole.customer.name,
        UserRole.host.name,
      ],
      currentUserId: currentUserId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: FutureBuilder<List<User>>(
        future: _fetchCustomers(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomProgressIndicator();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const NoDataFound(
              title: 'No Customers Found',
              subTitle: 'There are no customers available in the system.',
            );
          } else {
            final customersList = snapshot.data!;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!Provider.of<SearchUsersProvider>(context, listen: false)
                  .customersListEquals(customersList)) {
                Provider.of<SearchUsersProvider>(context, listen: false)
                    .setCustomersList(customersList);
              }
            });

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  toolbarHeight: 80.0,
                  title: Consumer<SearchUsersProvider>(
                    builder: (context, searchProvider, _) {
                      return SearchBar(
                        hintText: 'Search Customers',
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
                        onChanged: searchProvider.filterCustomers,
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.fromLTRB(20.0, 0.0, 10.0, 0.0),
                        ),
                      );
                    },
                  ),
                ),
                Consumer<SearchUsersProvider>(
                  builder: (_, searchUsersProvider, __) {
                    final childCount = searchUsersProvider.isSearchFilterActive
                        ? searchUsersProvider.filteredCustomers.length
                        : searchUsersProvider.customersList.length;
                    if (childCount <= 0) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return const NoDataFound(
                              title: 'No Results Found!',
                              subTitle:
                                  'There are no customers matching your search criteria. Please try again with different key words.',
                            );
                          },
                          childCount: 1,
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final user = searchUsersProvider.isSearchFilterActive
                              ? searchUsersProvider.filteredCustomers[index]
                              : searchUsersProvider.customersList[index];

                          return UserDetailsTile(user: user);
                        },
                        childCount: childCount,
                      ),
                    );
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
