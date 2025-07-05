// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:food_court/models/review.dart';

class ReviewWidget extends StatelessWidget {
  final String id;
  final String userName;
  final String comment;
  final int rating;

  const ReviewWidget({
    Key? key,
    required this.id,
    this.userName = 'Anonymous',
    this.comment = 'No comment provided.',
    this.rating = 5,
    required Review review,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review ID: $id',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('User: $userName'),
            const SizedBox(height: 8),
            Text('Rating: $rating / 5'),
            const SizedBox(height: 8),
            Text(comment),
          ],
        ),
      ),
    );
  }
}
