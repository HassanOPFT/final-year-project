import 'package:flutter/material.dart';
import 'dart:math';

class IssueReportProgressIndicator extends StatelessWidget {
  final int open;
  final Color openColor;
  final int inProgress;
  final Color inProgressColor;
  final int resolved;
  final Color resolvedColor;
  final int closed;
  final Color closedColor;

  const IssueReportProgressIndicator({
    super.key,
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.closed,
    required this.openColor,
    required this.inProgressColor,
    required this.resolvedColor,
    required this.closedColor,
  });

  @override
  Widget build(BuildContext context) {
    final total = open + inProgress + resolved + closed;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(270, 270),
              painter: CircularIssueReportPainter(
                open: open,
                openColor: openColor,
                inProgress: inProgress,
                inProgressColor: inProgressColor,
                resolved: resolved,
                resolvedColor: resolvedColor,
                closed: closed,
                closedColor: closedColor,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$total',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Total',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                LegendItem(
                  color: Colors.blue,
                  value: open,
                  label: 'Open',
                ),
                const SizedBox(height: 5),
                LegendItem(
                  color: Colors.yellow,
                  value: inProgress,
                  label: 'In Progress',
                ),
                const SizedBox(height: 5),
                LegendItem(
                  color: Colors.green,
                  value: resolved,
                  label: 'Resolved',
                ),
                const SizedBox(height: 5),
                LegendItem(
                  color: Colors.red,
                  value: closed,
                  label: 'Closed',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final int value;
  final String label;

  const LegendItem({
    super.key,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text('$label: $value'),
      ],
    );
  }
}

class CircularIssueReportPainter extends CustomPainter {
  final int open;
  final Color openColor;
  final int inProgress;
  final Color inProgressColor;
  final int resolved;
  final Color resolvedColor;
  final int closed;
  final Color closedColor;
  final int total;

  CircularIssueReportPainter({
    required this.openColor,
    required this.inProgressColor,
    required this.resolvedColor,
    required this.closedColor,
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.closed,
  }) : total = open + inProgress + resolved + closed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 20.0;

    double startAngle = -pi / 2;
    final openAngle = (open / total) * 2 * pi;
    final inProgressAngle = (inProgress / total) * 2 * pi;
    final resolvedAngle = (resolved / total) * 2 * pi;
    final closedAngle = (closed / total) * 2 * pi;

    // Open
    paint.color = openColor;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        openAngle, false, paint);
    startAngle += openAngle;

    // In Progress
    paint.color = inProgressColor;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        inProgressAngle, false, paint);
    startAngle += inProgressAngle;

    // Resolved
    paint.color = resolvedColor;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        resolvedAngle, false, paint);
    startAngle += resolvedAngle;

    // Closed
    paint.color = closedColor;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        closedAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
