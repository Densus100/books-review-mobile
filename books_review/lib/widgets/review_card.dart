import 'package:flutter/material.dart';
import '../models/review.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('User: ${review.userId}', style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                Row(
                  children: List.generate(5, (i) => Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber, size: 18)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.review, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
