import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';
import '../../models/status_history.dart';
import '../controllers/user_controller.dart';
import '../views/profile/verification_document_history_screen.dart';

class LatestStatusHistoryRecord extends StatelessWidget {
  final Future<StatusHistory?> Function(String verificationDocumentId)
      fetchStatusHistory;
  final String linkedObjectId;

  const LatestStatusHistoryRecord({
    super.key,
    required this.fetchStatusHistory,
    required this.linkedObjectId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Status History',
              style: TextStyle(
                fontSize: 24.0,
              ),
            ),
            const SizedBox(height: 10.0),
            FutureBuilder<StatusHistory?>(
              future: fetchStatusHistory(linkedObjectId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CustomProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading status history'),
                  );
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: Text('No status history available'),
                  );
                } else {
                  final latestStatusHistory = snapshot.data!;

                  final userController = UserController();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Map<String, String?>>(
                        future: userController.getUserNameAndPhoneNo(
                          latestStatusHistory.modifiedById!,
                        ),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (userSnapshot.hasError) {
                            return const Text('Error loading user details');
                          } else if (!userSnapshot.hasData ||
                              userSnapshot.data == null) {
                            return const Text('User details not found');
                          } else {
                            final userName =
                                '${userSnapshot.data?['userFirstName'] ?? ''} ${userSnapshot.data?['userLastName'] ?? ''}';
                            // final modifiedBy = userName;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.history_rounded,
                                    size: 30.0,
                                  ),
                                  title: Text(
                                    '${latestStatusHistory.newStatus}',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (latestStatusHistory
                                                  .statusDescription !=
                                              null &&
                                          latestStatusHistory
                                              .statusDescription!.isNotEmpty)
                                        Text(
                                          latestStatusHistory
                                              .statusDescription!,
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color:
                                                Theme.of(context).dividerColor,
                                          ),
                                        ),
                                      Text(
                                        latestStatusHistory.createdAt != null
                                            ? DateFormat.yMMMd()
                                                .add_jm()
                                                .format(latestStatusHistory
                                                    .createdAt!)
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
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () => animatedPushNavigation(
                                        context: context,
                                        screen:
                                            VerificationDocumentHistoryScreen(
                                          verificationDocumentId:
                                              latestStatusHistory
                                                      .linkedObjectId ??
                                                  '',
                                        ),
                                      ),
                                      child: const Text(
                                        'View All History',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
