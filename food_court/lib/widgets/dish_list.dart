import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/dish.dart';
import '../widgets/dish_card.dart';

class DishList extends StatelessWidget {
  final String searchQuery;
  final String selectedCuisine;
  final Function(Dish) onDishTap;

  const DishList({
    required this.searchQuery,
    required this.selectedCuisine,
    required this.onDishTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('dishes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading dishes'));
        }
        final dishes = snapshot.data!.docs
            .map((doc) => Dish.fromFirestore(doc))
            .where(
              (dish) =>
                  (selectedCuisine == 'All' || dish.cuisine == selectedCuisine) &&
                  dish.title.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();
        return AnimationLimiter(
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: dishes.length,
            separatorBuilder: (context, index) => SizedBox(height: 16),
            itemBuilder: (context, index) {
              final dish = dishes[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: GestureDetector(
                      onTap: () => onDishTap(dish),
                      child: DishCard(dish: dish),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
