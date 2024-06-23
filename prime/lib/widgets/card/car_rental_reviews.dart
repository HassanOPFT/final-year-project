// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime/models/car_rental.dart';
import 'package:prime/models/user.dart';
import 'package:prime/providers/car_rental_provider.dart';
import 'package:prime/providers/user_provider.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:provider/provider.dart';

import '../../views/rentals/car_reviews_screen.dart';

class CarRentalReviews extends StatelessWidget {
  final String carId;

  const CarRentalReviews({super.key, required this.carId});

  Future<Map<String, dynamic>> fetchReviewData(
    BuildContext context,
    String carId,
  ) async {
    // Fetch rentals for the given carId
    final rentals = await Provider.of<CarRentalProvider>(
      context,
      listen: false,
    ).getCarRentalsByCarId(carId);

    // Filter rentals to include only those with ratings
    final filteredRentals = rentals.where((rental) {
      return rental.rating != null && rental.rating! > 0;
    }).toList();

    // Initialize review statistics
    double totalRating = 0;
    int reviewCount = filteredRentals.length;
    Map<int, int> starCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    // Calculate total rating and star counts if there are reviews
    if (reviewCount > 0) {
      for (var rental in filteredRentals) {
        totalRating += rental.rating!;
        starCounts[rental.rating!.toInt()] =
            starCounts[rental.rating!.toInt()]! + 1;
      }
    }

    // Calculate overall rating and star percentages
    double overallRating = reviewCount > 0 ? totalRating / reviewCount : 0;
    Map<int, double> starPercentages = starCounts.map(
      (star, count) =>
          MapEntry(star, reviewCount > 0 ? count / reviewCount : 0),
    );

    // Find the most recent rental
    filteredRentals.sort(
        (a, b) => b.createdAt?.compareTo(a.createdAt ?? DateTime.now()) ?? 0);
    final mostRecentRental =
        filteredRentals.isNotEmpty ? filteredRentals.first : null;

    // Fetch the most recent reviewer details if there is a most recent rental
    final mostRecentReviewer = mostRecentRental != null
        ? await Provider.of<UserProvider>(
            context,
            listen: false,
          ).getUserDetails(mostRecentRental.customerId ?? '')
        : null;

    // Return the review data
    return {
      'overallRating': overallRating,
      'reviewCount': reviewCount,
      'starPercentages': starPercentages,
      'mostRecentRental': mostRecentRental,
      'mostRecentReviewer': mostRecentReviewer,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchReviewData(context, carId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading reviews.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No reviews available.'));
        }

        final reviewData = snapshot.data!;
        final overallRating = reviewData['overallRating'] as double? ?? 0.0;
        final reviewCount = reviewData['reviewCount'] as int? ?? 0;
        final starPercentages =
            reviewData['starPercentages'] as Map<int, double>? ??
                {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
        final mostRecentRental = reviewData['mostRecentRental'] as CarRental?;
        final mostRecentReviewer = reviewData['mostRecentReviewer'] as User?;

        return Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Reviews',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        overallRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 48.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Row(
                        children: List.generate(5, (index) {
                          final starIndex = index + 1;
                          return Icon(
                            starIndex <= overallRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24.0,
                          );
                        }),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        reviewCount.toString(),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      children: List.generate(5, (index) {
                        final starIndex = 5 - index;
                        return RatingBar(
                          rating: starIndex,
                          percentage: starPercentages[starIndex] ?? 0,
                        );
                      }),
                    ),
                  ),
                ],
              ),
              if (reviewCount > 0) const SizedBox(height: 16.0),
              if (reviewCount > 0)
                ListTile(
                  leading: ClipOval(
                    child: (mostRecentReviewer?.userProfileUrl?.isNotEmpty ??
                            false)
                        ? CachedNetworkImage(
                            imageUrl: mostRecentReviewer!.userProfileUrl!,
                            width: 50.0,
                            height: 50.0,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          )
                        : const Icon(Icons.person),
                  ),
                  title: Text(
                    '${mostRecentReviewer?.userFirstName ?? ''} ${mostRecentReviewer?.userLastName ?? ''}',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      mostRecentRental?.review != null
                          ? Text(mostRecentRental!.review.toString())
                          : Text(
                              'Joined on ${DateFormat.yMMM().format(mostRecentReviewer?.createdAt ?? DateTime.now())}',
                            ),
                      if (mostRecentRental?.endDate != null)
                        Text(
                          DateFormat.yMMMd()
                              .add_jm()
                              .format(mostRecentRental!.endDate!),
                          style: TextStyle(
                            fontSize: 13.0,
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (index) {
                        final starIndex = index + 1;
                        return Icon(
                          starIndex <= (mostRecentRental?.rating ?? 0)
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20.0,
                        );
                      },
                    ),
                  ),
                ),
              if (reviewCount > 0)
                TextButton(
                  onPressed: () => animatedPushNavigation(
                    context: context,
                    screen: CarReviewsScreen(carId: carId),
                  ),
                  child: const Text('View all Reviews'),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text('No reviews yet'),
                ),
            ],
          ),
        );
      },
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
