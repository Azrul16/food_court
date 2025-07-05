import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/restaurant.dart';
import '../widgets/restaurant_card.dart';

class RestaurantList extends StatelessWidget {
  final String searchQuery;
  final String selectedCuisine;

  const RestaurantList({
    required this.searchQuery,
    required this.selectedCuisine,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading restaurants'));
          }
          final restaurants = snapshot.data!.docs
              .map((doc) => Restaurant.fromFirestore(doc))
              .where(
                (restaurant) =>
                    (selectedCuisine == 'All' || restaurant.cuisine == selectedCuisine) &&
                    restaurant.title.toLowerCase().contains(searchQuery.toLowerCase()),
              )
              .toList();
          return AnimationLimiter(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: restaurants.length,
              separatorBuilder: (context, index) => SizedBox(width: 16),
              itemBuilder: (context, index) {
                final restaurant = restaurants[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: RestaurantCard(restaurant: restaurant),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
