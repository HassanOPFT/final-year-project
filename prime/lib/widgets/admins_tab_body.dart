import 'package:flutter/material.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/views/admin/create_admin_screen.dart';
import 'package:provider/provider.dart';
import '../providers/search_users_provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../services/firebase/firebase_auth_service.dart';
import 'custom_progress_indicator.dart';
import 'no_data_found.dart';
import 'tiles/user_details_tile.dart';

class AdminsTabBody extends StatefulWidget {
  const AdminsTabBody({super.key});

  @override
  State<AdminsTabBody> createState() => _AdminsTabBodyState();
}

class _AdminsTabBodyState extends State<AdminsTabBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<User>> _fetchAdmins(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = FirebaseAuthService().currentUser?.uid ?? '';

    return await userProvider.getUsers(
      usersRoles: [
        UserRole.primaryAdmin.name,
        UserRole.secondaryAdmin.name,
      ],
      currentUserId: currentUserId,
    );
  }

  Future<UserRole> _fetchCurrentUserRole(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final firebaseAuthService = FirebaseAuthService();
    String currentUserId = firebaseAuthService.currentUser?.uid ?? '';

    return await userProvider.getUserRole(currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context);
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {});
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: FutureBuilder<List<User>>(
              future: _fetchAdmins(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CustomProgressIndicator();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const NoDataFound(
                    title: 'No Admins Found',
                    subTitle:
                        'There are no other admins available in the system.',
                  );
                } else {
                  final adminsList = snapshot.data!;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!Provider.of<SearchUsersProvider>(context,
                            listen: false)
                        .customersListEquals(adminsList)) {
                      Provider.of<SearchUsersProvider>(context, listen: false)
                          .setCustomersList(adminsList);
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
                              hintText: 'Search Admins',
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
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.fromLTRB(20.0, 0.0, 10.0, 0.0),
                              ),
                            );
                          },
                        ),
                      ),
                      Consumer<SearchUsersProvider>(
                        builder: (_, searchUsersProvider, __) {
                          final childCount =
                              searchUsersProvider.isSearchFilterActive
                                  ? searchUsersProvider.filteredCustomers.length
                                  : searchUsersProvider.customersList.length;
                          if (childCount <= 0) {
                            return SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return const NoDataFound(
                                    title: 'No Results Found!',
                                    subTitle:
                                        'There are no admins matching your search criteria. Please try again with different key words.',
                                  );
                                },
                                childCount: 1,
                              ),
                            );
                          }
                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final user = searchUsersProvider
                                        .isSearchFilterActive
                                    ? searchUsersProvider
                                        .filteredCustomers[index]
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
          ),
          FutureBuilder<UserRole>(
            future: _fetchCurrentUserRole(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                final currentUserRole = snapshot.data;
                if (currentUserRole == UserRole.primaryAdmin) {
                  return Positioned(
                    bottom: 16.0,
                    right: 16.0,
                    child: FloatingActionButton.extended(
                      onPressed: () => animatedPushNavigation(
                        context: context,
                        screen: const CreateAdminScreen(),
                      ),
                      label: const Text('Add New Admin'),
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                    ),
                  );
                }
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
