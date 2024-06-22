import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/controllers/user_controller.dart';
import 'package:prime/models/status_history.dart';
import 'package:prime/providers/status_history_provider.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';

class StatusHistoryScreen extends StatelessWidget {
  final String linkedObjectId;

  const StatusHistoryScreen({
    super.key,
    required this.linkedObjectId,
  });

  @override
  Widget build(BuildContext context) {
    final statusHistoryProvider = Provider.of<StatusHistoryProvider>(
      context,
      listen: false,
    );
    final userController = UserController();

    final Future<List<StatusHistory>> statusHistoryList =
        statusHistoryProvider.getStatusHistoryList(
      linkedObjectId,
    );

    Future<Map<String, String?>> fetchUserNames(
        List<StatusHistory> histories) async {
      Map<String, String?> userNames = {};
      for (var history in histories) {
        if (history.modifiedById != null &&
            !userNames.containsKey(history.modifiedById)) {
          final userNameAndPhoneNoMap =
              await userController.getUserNameAndPhoneNo(history.modifiedById!);
          userNames[history.modifiedById!] =
              '${userNameAndPhoneNoMap['userFirstName']} ${userNameAndPhoneNoMap['userLastName']}';
        }
      }
      return userNames;
    }

    final Future<Map<String, dynamic>> combinedFuture =
        statusHistoryList.then((histories) async {
      final userNames = await fetchUserNames(histories);
      return {
        'histories': histories,
        'userNames': userNames,
      };
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status History'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: combinedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomProgressIndicator();
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading history'));
          } else if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!['histories'].isEmpty) {
            return const Center(child: Text('No history available'));
          } else {
            final List<StatusHistory> statusHistoryList =
                snapshot.data!['histories'];
            final Map<String, String?> userNames = snapshot.data!['userNames'];

            return ListView.builder(
              itemCount: statusHistoryList.length,
              itemBuilder: (context, index) {
                final history = statusHistoryList[index];
                final userName =
                    userNames[history.modifiedById] ?? 'User details not found';

                return ListTile(
                  leading: Icon(
                    Icons.history_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 30.0,
                  ),
                  title: Text(
                    '${history.newStatus}',
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
    );
  }
}
