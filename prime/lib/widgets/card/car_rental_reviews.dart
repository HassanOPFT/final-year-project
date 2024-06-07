import 'package:flutter/material.dart';

class CarRentalReviews extends StatelessWidget {
  const CarRentalReviews({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 20.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '4.2',
                style: TextStyle(
                  fontSize: 48.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5.0),
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24.0,
                  ),
                  Icon(
                    Icons.star_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24.0,
                  ),
                  Icon(
                    Icons.star_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24.0,
                  ),
                  Icon(
                    Icons.star_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24.0,
                  ),
                  Icon(
                    Icons.star_half_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24.0,
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              Text(
                '18,929,156',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16.0),
          const Expanded(
            child: Column(
              children: [
                RatingBar(rating: 5, percentage: 0.6),
                RatingBar(rating: 4, percentage: 0.25),
                RatingBar(rating: 3, percentage: 0.1),
                RatingBar(rating: 2, percentage: 0.03),
                RatingBar(rating: 1, percentage: 0.02),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RatingBar extends StatelessWidget {
  final int rating;
  final double percentage;

  const RatingBar({
    super.key,
    required this.rating,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$rating'),
        const SizedBox(width: 8.0),
        Expanded(
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Theme.of(context).focusColor,
            minHeight: 8.0,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ],
    );
  }
}
