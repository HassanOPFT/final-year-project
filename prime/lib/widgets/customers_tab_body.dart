import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import 'no_data_found.dart';
import 'tiles/user_details_tile.dart';

class CustomersTabBody extends StatelessWidget {
  const CustomersTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return FutureBuilder<List<User>>(
      future: userProvider.getUsers([
        UserRole.customer.name,
        UserRole.host.name,
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('Error while loading customers');
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              return UserDetailsTile(user: user);
            },
          );
        } else {
          return const NoDataFound(
            title: 'No Customers Found',
            subTitle: 'There are no customers available in the system.',
          );
        }
      },
    );
  }
}
