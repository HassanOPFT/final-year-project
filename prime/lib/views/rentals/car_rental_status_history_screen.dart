import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/controllers/user_controller.dart';
import 'package:prime/models/status_history.dart';
import 'package:prime/providers/status_history_provider.dart';
import 'package:prime/services/firebase/firebase_auth_service.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';

import '../../models/car_rental.dart';
import '../../models/user.dart';

class CarRentalStatusHistoryScreen extends StatefulWidget {
  final String linkedObjectId;

  const CarRentalStatusHistoryScreen({
    super.key,
    required this.linkedObjectId,
  });

  @override
  State<CarRentalStatusHistoryScreen> createState() =>
      _CarRentalStatusHistoryScreenState();
}

class _CarRentalStatusHistoryScreenState
    extends State<CarRentalStatusHistoryScreen> {
  Future<Map<String, dynamic>> fetchCombinedData(String linkedObjectId) async {
    final statusHistoryProvider = StatusHistoryProvider();
    final userController = UserController();

    final List<StatusHistory> statusHistoryList =
        await statusHistoryProvider.getStatusHistoryList(linkedObjectId);
    final currentUserId = FirebaseAuthService().currentUser?.uid;
    final currentUserRole =
        await userController.getUserRole(currentUserId ?? '');

    Map<String, String?> userNames = {};
    for (var history in statusHistoryList) {
      if (history.modifiedById != null &&
          !userNames.containsKey(history.modifiedById)) {
        final userNameAndPhoneNoMap =
            await userController.getUserNameAndPhoneNo(history.modifiedById!);
        userNames[history.modifiedById!] =
            '${userNameAndPhoneNoMap['userFirstName']} ${userNameAndPhoneNoMap['userLastName']}';
      }
    }

    return {
      'statusHistoryList': statusHistoryList,
      'userNames': userNames,
      'currentUserRole': currentUserRole,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status History'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchCombinedData(widget.linkedObjectId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomProgressIndicator();
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading history'));
            } else if (!snapshot.hasData ||
                snapshot.data == null ||
                snapshot.data!['statusHistoryList'].isEmpty) {
              return const Center(child: Text('No history available'));
            } else {
              final List<StatusHistory> statusHistoryList =
                  snapshot.data!['statusHistoryList'];
              final Map<String, String?> userNames =
                  snapshot.data!['userNames'];
              final UserRole currentUserRole =
                  snapshot.data!['currentUserRole'];

              return ListView.builder(
                itemCount: statusHistoryList.length,
                itemBuilder: (context, index) {
                  final history = statusHistoryList[index];
                  final userName = userNames[history.modifiedById] ??
                      'User details not found';
                  final title = CarRentalStatusExtension.fromString(
                          history.newStatus ?? '')
                      .getStatusString(currentUserRole);

                  return ListTile(
                    leading: Icon(
                      Icons.history_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30.0,
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (history.statusDescription != null &&
                            history.statusDescription!.isNotEmpty)
                          Text(
                            history.statusDescription!,
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        Text(
                          history.createdAt != null
                              ? DateFormat.yMMMd()
                                  .add_jm()
                                  .format(history.createdAt!)
                              : 'Unknown',
                          style: TextStyle(
                            fontSize: 13.0,
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      userName,
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
