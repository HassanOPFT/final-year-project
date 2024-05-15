import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'custom_progress_indicator.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return FutureBuilder<Map<String, String?>>(
      future: userProvider.getUserNameAndPhoneNo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomProgressIndicator();
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Error fetching user info');
        } else {
          final userInfo = snapshot.data!;
          return Column(
            children: [
              Text(
                '${userInfo['userFirstName'] ?? ''} ${userInfo['userLastName'] ?? ''}',
                style: const TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (userInfo['userPhoneNumber'] != null &&
                  userInfo['userPhoneNumber']!.isNotEmpty)
                Text(
                  userInfo['userPhoneNumber'] ?? '',
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          );
        }
      },
    );
  }
}
