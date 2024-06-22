import 'package:flutter/material.dart';
import '../../models/issue_report.dart';
import '../../models/user.dart';

class IssueReportBottomSheet extends StatelessWidget {
  final IssueReport issueReport;
  final UserRole? currentUserRole;
  final Function(IssueReport, UserRole) onSetInProgress;
  final Function(IssueReport, UserRole) onSetResolved;
  final Function(IssueReport, UserRole) onSetClosed;

  const IssueReportBottomSheet({
    super.key,
    required this.issueReport,
    this.currentUserRole,
    required this.onSetInProgress,
    required this.onSetResolved,
    required this.onSetClosed,
  });

  Widget _setInProgressButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Navigator.of(context).pop();
        onSetInProgress(issueReport, currentUserRole!);
      },
      icon: const Icon(Icons.timelapse),
      label: const Text(
        'Set as In Progress',
        style: TextStyle(
          fontSize: 18.0,
        ),
      ),
    );
  }

  Widget _setResolvedButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Navigator.of(context).pop();
        onSetResolved(issueReport, currentUserRole!);
      },
      icon: const Icon(Icons.check_circle_rounded),
      label: const Text(
        'Set as Resolved',
        style: TextStyle(
          fontSize: 18.0,
        ),
      ),
    );
  }

  Widget _setClosedButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Navigator.of(context).pop();
        onSetClosed(issueReport, currentUserRole!);
      },
      icon: const Icon(
        Icons.close_rounded,
        color: Colors.red,
      ),
      label: const Text(
        'Set as Closed',
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.red,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actionButtons = [];

    if (issueReport.status == IssueReportStatus.open) {
      actionButtons.addAll([
        _setInProgressButton(context),
        _setResolvedButton(context),
        _setClosedButton(context),
      ]);
    } else if (issueReport.status == IssueReportStatus.inProgress) {
      actionButtons.addAll([
        _setResolvedButton(context),
        _setClosedButton(context),
      ]);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Manage Issue Report',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5.0),
          const Divider(),
          const SizedBox(height: 15.0),
          if (actionButtons.isNotEmpty)
            ...actionButtons
          else
            const Text(
              'No actions available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
        ],
      ),
    );
  }
}
