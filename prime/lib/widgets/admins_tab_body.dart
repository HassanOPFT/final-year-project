import 'package:flutter/material.dart';
import 'package:prime/widgets/tiles/user_details_tile.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../services/firebase/firebase_auth_service.dart';
import 'no_data_found.dart';

class AdminsTabBody extends StatelessWidget {
  const AdminsTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseAuthService = FirebaseAuthService();
    String currentUserId = '';
    if (firebaseAuthService.currentUser != null) {
      currentUserId = firebaseAuthService.currentUser?.uid as String;
    }
    final userProvider = Provider.of<UserProvider>(context);
    return FutureBuilder<List<User>>(
      future: userProvider.getUsers([
        UserRole.primaryAdmin.name,
        UserRole.secondaryAdmin.name,
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('Error while loading admins');
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              if (currentUserId == user.userId) {
                return UserDetailsTile(user: user);
              }
              return null;
            },
          );
        } else {
          return const NoDataFound(
            title: 'No Admins Found',
            subTitle: 'There are no admins available in the system.',
          );
        }
      },
    );
  }
}
