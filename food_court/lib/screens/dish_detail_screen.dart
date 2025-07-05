import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dish.dart';
import '../models/review.dart';
import '../widgets/review_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DishDetailScreen extends StatefulWidget {
  final Dish dish;

  DishDetailScreen({required this.dish});

  @override
  _DishDetailScreenState createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  final _reviewController = TextEditingController();
  int _starRating = 5;
  final _formKey = GlobalKey<FormState>();

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to submit a review')),
      );
      return;
    }
    final review = Review(
      id: '',
      userId: user.uid,
      targetId: widget.dish.id,
      description: _reviewController.text.trim(),
      stars: _starRating,
    );
    try {
      await FirebaseFirestore.instance
          .collection('reviews')
          .add(review.toMap());
      _reviewController.clear();
      setState(() {
        _starRating = 5;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Review submitted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit review: $e')));
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dish.title),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.dish.image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16),
            Text(
              widget.dish.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.dish.slogan,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              '\$${widget.dish.price.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.orangeAccent, fontSize: 20),
            ),
            SizedBox(height: 24),
            Text(
              'Reviews',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('reviews')
                      .where('targetId', isEqualTo: widget.dish.id)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                final reviews =
                    snapshot.data!.docs
                        .map(
                          (doc) => Review.fromMap(
                            doc.data() as Map<String, dynamic>,
                            doc.id,
                          ),
                        )
                        .toList();
                if (reviews.isEmpty) {
                  return Text(
                    'No reviews yet.',
                    style: TextStyle(color: Colors.white70),
                  );
                }
                return Column(
                  children:
                      reviews
                          .map((review) => ReviewWidget(review: review, id: ''))
                          .toList(),
                );
              },
            ),
            SizedBox(height: 24),
            Text(
              'Add a Review',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _reviewController,
                    maxLines: 3,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Write your review here',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a review';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _starRating ? Icons.star : Icons.star_border,
                          color: Colors.orangeAccent,
                        ),
                        onPressed: () {
                          setState(() {
                            _starRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _submitReview,
                    child: Text('Submit Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
