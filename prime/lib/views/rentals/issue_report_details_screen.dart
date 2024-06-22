// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:prime/services/firebase/firebase_auth_service.dart';
import 'package:prime/widgets/created_at_row.dart';
import 'package:prime/widgets/reference_number_row.dart';
import 'package:provider/provider.dart';
import '../../models/issue_report.dart';
import '../../models/status_history.dart';
import '../../models/user.dart';
import '../../models/car.dart';
import '../../models/car_rental.dart';
import '../../providers/status_history_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/car_provider.dart';
import '../../providers/car_rental_provider.dart';
import '../../providers/issue_report_provider.dart';
import '../../utils/launch_core_service_util.dart';
import '../../utils/navigate_with_animation.dart';
import '../../utils/snackbar.dart';
import '../../widgets/bottom_sheet/edit_issue_report_bottom_sheet.dart';
import '../../widgets/issue_report_status_indicator.dart';
import '../../widgets/latest_status_history_record.dart';
import '../../widgets/tiles/car_rental_card.dart';
import '../admin/user_details_screen.dart';

class IssueReportDetailsScreen extends StatelessWidget {
  final String issueReportId;

  const IssueReportDetailsScreen({
    super.key,
    required this.issueReportId,
  });

  @override
  Widget build(BuildContext context) {
    Future<Map<String, dynamic>> fetchIssueReportDetails() async {
      final issueReportProvider = Provider.of<IssueReportProvider>(
        context,
      );
      final carRentalProvider = Provider.of<CarRentalProvider>(
        context,
        listen: false,
      );
      final carProvider = Provider.of<CarProvider>(
        context,
        listen: false,
      );
      final userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );

      final issueReport = await issueReportProvider.getIssueReportById(
        issueReportId,
      );

      final carRental = await carRentalProvider.getCarRentalById(
        issueReport?.carRentalId ?? '',
      );

      final car = await carProvider.getCarById(
        carRental?.carId ?? '',
      );

      final host = await userProvider.getUserDetails(
        car?.hostId ?? '',
      );

      final customer = await userProvider.getUserDetails(
        carRental?.customerId ?? '',
      );

      String currentUserId = FirebaseAuthService().currentUser?.uid ?? '';
      UserRole? currentUserRole;
      if (currentUserId == car?.hostId) {
        currentUserRole = UserRole.host;
      } else if (currentUserId == carRental?.customerId) {
        currentUserRole = UserRole.customer;
      } else {
        final userRole = await userProvider.getUserRole(currentUserId);
        if (userRole == UserRole.primaryAdmin ||
            userRole == UserRole.secondaryAdmin) {
          currentUserRole = userRole;
        }
      }

      final reporter =
          issueReport?.reporterId == carRental?.customerId ? customer : host;

      final otherParty =
          issueReport?.reporterId == carRental?.customerId ? host : customer;

      return {
        'issueReport': issueReport,
        'carRental': carRental,
        'car': car,
        'currentUserRole': currentUserRole,
        'reporter': reporter,
        'otherParty': otherParty,
      };
    }

    Future<String?> showActionDescriptionDialog({
      required BuildContext context,
      required String title,
      required String hintText,
    }) async {
      final TextEditingController descriptionController =
          TextEditingController();
      final formKey = GlobalKey<FormState>();

      return showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(title),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: descriptionController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        labelText: hintText,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().isEmpty) {
                          return 'Please enter a description.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop(descriptionController.text);
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );
    }

    Future<void> setIssueReportInProgress(
      IssueReport issueReport,
      UserRole currentUserRole,
    ) async {
      if (currentUserRole != UserRole.primaryAdmin &&
          currentUserRole != UserRole.secondaryAdmin) {
        buildAlertSnackbar(
          context: context,
          message: 'You don\'t have permission to modify this issue report.',
        );
        return;
      }

      final issueReportProvider = Provider.of<IssueReportProvider>(
        context,
        listen: false,
      );
      String currentUserId = FirebaseAuthService().currentUser?.uid ?? '';

      try {
        await issueReportProvider.updateIssueReportStatus(
          issueReportId: issueReport.id ?? '',
          previousStatus: issueReport.status ?? IssueReportStatus.inProgress,
          newStatus: IssueReportStatus.inProgress,
          modifiedById: currentUserId,
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Issue report status updated to in progress successfully.',
        );
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message:
              'Error updating issue report status. Please try again later.',
        );
      }
    }

    Future<void> setIssueReportResolved(
      IssueReport issueReport,
      UserRole currentUserRole,
    ) async {
      if (currentUserRole != UserRole.primaryAdmin &&
          currentUserRole != UserRole.secondaryAdmin) {
        buildAlertSnackbar(
          context: context,
          message: 'You don\'t have permission to modify this issue report.',
        );
        return;
      }
      final issueReportProvider = Provider.of<IssueReportProvider>(
        context,
        listen: false,
      );

      final resolutionDescription = await showActionDescriptionDialog(
        context: context,
        title: 'Resolution Description',
        hintText: 'Enter resolution description',
      );

      if (resolutionDescription == null || resolutionDescription.isEmpty) {
        return;
      }

      try {
        String currentUserId = FirebaseAuthService().currentUser?.uid ?? '';
        await issueReportProvider.updateIssueReportStatus(
          issueReportId: issueReport.id ?? '',
          previousStatus: issueReport.status ?? IssueReportStatus.inProgress,
          newStatus: IssueReportStatus.resolved,
          statusDescription: resolutionDescription,
          modifiedById: currentUserId,
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Issue report has been resolved successfully.',
        );
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message:
              'Error updating issue report status. Please try again later.',
        );
      }
    }

    Future<void> setIssueReportClosed(
      IssueReport issueReport,
      UserRole currentUserRole,
    ) async {
      if (currentUserRole != UserRole.primaryAdmin &&
          currentUserRole != UserRole.secondaryAdmin) {
        buildAlertSnackbar(
          context: context,
          message: 'You don\'t have permission to modify this issue report.',
        );
        return;
      }

      final closingDescription = await showActionDescriptionDialog(
        context: context,
        title: 'Closing Description',
        hintText: 'Enter closing description',
      );

      if (closingDescription == null || closingDescription.isEmpty) {
        return;
      }

      final issueReportProvider = Provider.of<IssueReportProvider>(
        context,
        listen: false,
      );
      try {
        String currentUserId = FirebaseAuthService().currentUser?.uid ?? '';
        await issueReportProvider.updateIssueReportStatus(
          issueReportId: issueReport.id ?? '',
          previousStatus: issueReport.status ?? IssueReportStatus.inProgress,
          newStatus: IssueReportStatus.closed,
          statusDescription: closingDescription,
          modifiedById: currentUserId,
        );
        buildSuccessSnackbar(
          context: context,
          message: 'Issue report has been closed successfully.',
        );
      } on Exception catch (_) {
        buildFailureSnackbar(
          context: context,
          message:
              'Error updating issue report status. Please try again later.',
        );
      }
    }

    Future<void> showIssueReportBottomSheet(
      IssueReport? issueReport,
      UserRole? currentUserRole,
    ) async {
      if (issueReport == null) {
        return;
      }
      await showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (BuildContext context) {
          return IssueReportBottomSheet(
            issueReport: issueReport,
            currentUserRole: currentUserRole,
            onSetInProgress: setIssueReportInProgress,
            onSetResolved: setIssueReportResolved,
            onSetClosed: setIssueReportClosed,
          );
        },
      );
    }

    Future<StatusHistory?> getMostRecentIssueReportStatusHistory(
      String? issueReportId,
    ) async {
      if (issueReportId == null || issueReportId.isEmpty) {
        return null;
      }
      try {
        final statusHistoryProvider = Provider.of<StatusHistoryProvider>(
          context,
        );
        final mostRecentStatusHistory =
            await statusHistoryProvider.getMostRecentStatusHistory(
          issueReportId,
        );
        return mostRecentStatusHistory;
      } catch (_) {
        return null;
      }
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: fetchIssueReportDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Issue Report Details')),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Issue Report Details')),
            body: const Center(
              child: Text('Error loading data'),
            ),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Issue Report Details')),
            body: const Center(child: Text('No data available')),
          );
        } else {
          final IssueReport? issueReport = snapshot.data!['issueReport'];
          final CarRental? carRental = snapshot.data!['carRental'];
          final Car? car = snapshot.data!['car'];
          final UserRole? currentUserRole = snapshot.data!['currentUserRole'];
          final User? reporter = snapshot.data!['reporter'];
          final User? otherParty = snapshot.data!['otherParty'];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Issue Report Details'),
              actions: [
                if (currentUserRole == UserRole.primaryAdmin ||
                    currentUserRole == UserRole.secondaryAdmin)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => showIssueReportBottomSheet(
                      issueReport,
                      currentUserRole,
                    ),
                  ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 5.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status',
                          style: TextStyle(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        IssueReportStatusIndicator(
                          issueReportStatus: issueReport?.status ??
                              IssueReportStatus.inProgress,
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(thickness: 0.3),
                    ),
                    Text(
                      'Subject',
                      style: TextStyle(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    Text(
                      issueReport?.reportSubject ?? 'No Subject',
                      style: const TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      'Description',
                      style: TextStyle(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    Text(
                      issueReport?.reportDescription ?? 'No Description',
                      style: const TextStyle(
                        fontSize: 26.0,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(thickness: 0.3),
                    ),
                    if (currentUserRole == UserRole.primaryAdmin ||
                        currentUserRole == UserRole.secondaryAdmin)
                      AdminIssueReportCarRentalDetails(
                        carRental: carRental,
                        car: car,
                      ),
                    buildUserDetailsSection(
                      context,
                      reporter,
                      otherParty,
                      currentUserRole == UserRole.primaryAdmin ||
                          currentUserRole == UserRole.secondaryAdmin,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(thickness: 0.3),
                    ),
                    LatestStatusHistoryRecord(
                      fetchStatusHistory: getMostRecentIssueReportStatusHistory,
                      linkedObjectId: issueReport?.id ?? '',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(thickness: 0.3),
                    ),
                    ReferenceNumberRow(
                      referenceNumber: issueReport?.referenceNumber,
                    ),
                    CreatedAtRow(
                      labelText: 'Reported At',
                      createdAt: issueReport?.createdAt,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Column buildUserDetailsSection(
    BuildContext context,
    User? reporter,
    User? otherParty,
    bool isAdmin,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reporter',
          style: TextStyle(
            color: Theme.of(context).dividerColor,
          ),
        ),
        const SizedBox(height: 10.0),
        UserTile(
          user: reporter ?? User(),
          isAdmin: isAdmin,
        ),
        const SizedBox(height: 20.0),
        Text(
          'Other Party',
          style: TextStyle(
            color: Theme.of(context).dividerColor,
          ),
        ),
        const SizedBox(height: 10.0),
        UserTile(
          user: otherParty ?? User(),
          isAdmin: isAdmin,
        ),
      ],
    );
  }
}

class AdminIssueReportCarRentalDetails extends StatelessWidget {
  const AdminIssueReportCarRentalDetails({
    super.key,
    required this.carRental,
    required this.car,
  });

  final CarRental? carRental;
  final Car? car;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Car Rental Details',
          style: TextStyle(
            color: Theme.of(context).dividerColor,
          ),
        ),
        const SizedBox(height: 5.0),
        CarRentalCard(
          carRental: carRental ?? CarRental(),
          car: car ?? Car(),
          userRole: UserRole.primaryAdmin,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Divider(thickness: 0.3),
        ),
      ],
    );
  }
}

class UserTile extends StatelessWidget {
  final User user;
  final bool isAdmin;

  const UserTile({
    super.key,
    required this.user,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => isAdmin
          ? animatedPushNavigation(
              context: context,
              screen: UserDetailsScreen(userId: user.userId ?? ''),
            )
          : null,
      child: ListTile(
        leading: ClipOval(
          child: user.userProfileUrl?.isNotEmpty ?? false
              ? CachedNetworkImage(
                  imageUrl: user.userProfileUrl!,
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
              : const Icon(Icons.person),
        ),
        title: Text(
          '${user.userFirstName} ${user.userLastName}',
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          user.userPhoneNumber ?? 'N/A',
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.phone,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => LaunchCoreServiceUtil.launchPhoneCall(
            user.userPhoneNumber,
          ),
        ),
      ),
    );
  }
}
