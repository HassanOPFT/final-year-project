import 'package:flutter/material.dart';
import 'dart:math';

class ProgressIndicatorWithLegend extends StatelessWidget {
  final double platformRevenue;
  final double hostsEarnings;
  final double stripeFees;

  const ProgressIndicatorWithLegend({
    super.key,
    required this.platformRevenue,
    required this.hostsEarnings,
    required this.stripeFees,
  });

  @override
  Widget build(BuildContext context) {
    final total = platformRevenue + hostsEarnings + stripeFees;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(270, 270),
              painter: CircularProgressPainter(
                platformRevenue: platformRevenue,
                hostsEarnings: hostsEarnings,
                stripeFees: stripeFees,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'RM${total.toStringAsFixed(2)}',
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
                  value: platformRevenue,
                  label: 'Platform Revenue',
                ),
                const SizedBox(height: 5),
                LegendItem(
                  color: Colors.green,
                  value: hostsEarnings,
                  label: 'Hosts Earnings',
                ),
                const SizedBox(height: 5),
                LegendItem(
                  color: Colors.orange,
                  value: stripeFees,
                  label: 'Stripe Fees',
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
  final double value;
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
        // make border radius circular
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text('$label: RM${value.toStringAsFixed(2)}'),
      ],
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double platformRevenue;
  final double hostsEarnings;
  final double stripeFees;
  final double total;

  CircularProgressPainter({
    required this.platformRevenue,
    required this.hostsEarnings,
    required this.stripeFees,
  }) : total = platformRevenue + hostsEarnings + stripeFees;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 20.0;

    double startAngle = -pi / 2;
    final platformRevenueAngle = (platformRevenue / total) * 2 * pi;
    final hostsEarningsAngle = (hostsEarnings / total) * 2 * pi;
    final stripeFeesAngle = (stripeFees / total) * 2 * pi;

    // Platform Revenue
    paint.color = Colors.blue;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        platformRevenueAngle, false, paint);
    startAngle += platformRevenueAngle;

    // Hosts Earnings
    paint.color = Colors.green;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        hostsEarningsAngle, false, paint);
    startAngle += hostsEarningsAngle;

    // Stripe Fees
    paint.color = Colors.orange;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        stripeFeesAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
