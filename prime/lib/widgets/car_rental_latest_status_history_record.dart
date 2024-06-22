import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/services/firebase/firebase_auth_service.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';
import '../../models/status_history.dart';
import '../controllers/user_controller.dart';
import '../models/car_rental.dart';
import '../models/user.dart';
import '../views/rentals/car_rental_status_history_screen.dart';

class CarRentalLatestStatusHistoryRecord extends StatelessWidget {
  final Future<StatusHistory?> Function(String verificationDocumentId)
      fetchStatusHistory;
  final String linkedObjectId;

  const CarRentalLatestStatusHistoryRecord({
    super.key,
    required this.fetchStatusHistory,
    required this.linkedObjectId,
  });

  Future<Map<String, dynamic>> fetchCombinedData(
    String linkedObjectId,
  ) async {
    final statusHistory = await fetchStatusHistory(linkedObjectId);
    final userController = UserController();
    Map<String, String?>? userDetails;
    if (statusHistory?.modifiedById != null) {
      userDetails = await userController
          .getUserNameAndPhoneNo(statusHistory!.modifiedById!);
    }
    final currentUserId = FirebaseAuthService().currentUser?.uid;
    final currentUserRole =
        await userController.getUserRole(currentUserId ?? '');
    return {
      'statusHistory': statusHistory,
      'userDetails': userDetails,
      'currentUserRole': currentUserRole,
    };
  }

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
            FutureBuilder<Map<String, dynamic>>(
              future: fetchCombinedData(linkedObjectId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CustomProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading data'),
                  );
                } else if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!['statusHistory'] == null) {
                  return const Center(
                    child: Text('No status history available'),
                  );
                } else {
                  final statusHistory =
                      snapshot.data!['statusHistory'] as StatusHistory;
                  final userDetails =
                      snapshot.data!['userDetails'] as Map<String, String?>?;
                  final title = CarRentalStatusExtension.fromString(
                      statusHistory.newStatus ?? '');
                  final UserRole userRole = snapshot.data!['currentUserRole'];
                  final userName = userDetails != null
                      ? '${userDetails['userFirstName'] ?? ''} ${userDetails['userLastName'] ?? ''}'
                      : 'Unknown User';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.history_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 30.0,
                        ),
                        title: Text(
                          title.getStatusString(userRole),
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (statusHistory.statusDescription != null &&
                                statusHistory.statusDescription!.isNotEmpty)
                              Text(
                                statusHistory.statusDescription!,
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                            Text(
                              statusHistory.createdAt != null
                                  ? DateFormat.yMMMd()
                                      .add_jm()
                                      .format(statusHistory.createdAt!)
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
                              screen: CarRentalStatusHistoryScreen(
                                linkedObjectId:
                                    statusHistory.linkedObjectId ?? '',
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
        ),
      ),
    );
  }
}
