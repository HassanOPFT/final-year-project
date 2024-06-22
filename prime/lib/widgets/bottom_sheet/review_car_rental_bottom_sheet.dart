import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../custom_progress_indicator.dart';

class ReviewCarRentalBottomSheet extends StatefulWidget {
  final String carImageUrl;
  final String carName;
  final String? carColor;
  final String rentalTotalAmount;

  const ReviewCarRentalBottomSheet({
    super.key,
    required this.carImageUrl,
    required this.carName,
    required this.carColor,
    required this.rentalTotalAmount,
  });

  @override
  State<ReviewCarRentalBottomSheet> createState() =>
      _ReviewCarRentalBottomSheetState();
}

class _ReviewCarRentalBottomSheetState
    extends State<ReviewCarRentalBottomSheet> {
  int _rating = 5;
  final TextEditingController _reviewController = TextEditingController();

  Widget _buildIconTextRow(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 5.0),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Leave a Review',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5.0),
          const Divider(),
          const SizedBox(height: 5.0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: CachedNetworkImage(
                    imageUrl: widget.carImageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CustomProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Center(child: Icon(Icons.error)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.carName,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      _buildIconTextRow(
                        context,
                        Icons.color_lens,
                        widget.carColor ?? 'N/A',
                      ),
                      const SizedBox(height: 8.0),
                      _buildIconTextRow(
                        context,
                        Icons.attach_money,
                        widget.rentalTotalAmount,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'How was your rental?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please give your rating & also your review...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).dividerColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 10.0),
          TextFormField(
            controller: _reviewController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              labelText: 'Review',
            ),
          ),
          const SizedBox(width: 16.0),
          Container(
            height: 50.0,
            margin: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 10.0),
            child: FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  {
                    'rating': _rating,
                    'review': _reviewController.text.isEmpty
                        ? null
                        : _reviewController.text,
                  },
                );
              },
              child: const Text(
                'Submit',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40.0,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
