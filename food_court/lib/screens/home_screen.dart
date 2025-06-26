import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../models/restaurant.dart';
import '../models/dish.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/dish_card.dart';
import '../widgets/section_title.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedCuisine = 'All';
  final TextEditingController _searchController = TextEditingController();

  List<String> cuisines = [
    'All',
    'Italian',
    'Chinese',
    'Indian',
    'Mexican',
    'Japanese',
    'Mediterranean',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Gourmet Express',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.pushNamed(context, '/admin_login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search and Filter Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search restaurants or dishes...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[500],
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCuisine,
                          isExpanded: true,
                          icon: Icon(
                            Icons.filter_list,
                            color: Colors.grey[500],
                          ),
                          dropdownColor: Colors.grey[900],
                          items:
                              cuisines.map((cuisine) {
                                return DropdownMenuItem<String>(
                                  value: cuisine,
                                  child: Text(
                                    cuisine,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCuisine = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              // Order Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (FirebaseAuth.instance.currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please login to place orders')),
                      );
                      Navigator.pushNamed(context, '/login');
                    } else {
                      Navigator.pushNamed(context, '/order');
                    }
                  },
                  child: Text('Place Order', style: TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(height: 24),
              // Featured Restaurants Section
              SectionTitle(title: 'Featured Restaurants'),
              SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      Provider.of<FirebaseService>(context).getRestaurants(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading restaurants'));
                    }
                    final restaurants =
                        snapshot.data!.docs
                            .map((doc) => Restaurant.fromFirestore(doc))
                            .where(
                              (restaurant) =>
                                  (_selectedCuisine == 'All' ||
                                      restaurant.cuisine == _selectedCuisine) &&
                                  restaurant.title.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ),
                            )
                            .toList();
                    return AnimationLimiter(
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: restaurants.length,
                        separatorBuilder:
                            (context, index) => SizedBox(width: 16),
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
              ),
              SizedBox(height: 32),
              // Popular Dishes Section
              SectionTitle(title: 'Popular Dishes'),
              SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('dishes').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading dishes'));
                  }
                  final dishes =
                      snapshot.data!.docs
                          .map((doc) => Dish.fromFirestore(doc))
                          .where(
                            (dish) =>
                                (_selectedCuisine == 'All' ||
                                    dish.cuisine == _selectedCuisine) &&
                                dish.title.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ),
                          )
                          .toList();
                  return AnimationLimiter(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: dishes.length,
                      separatorBuilder:
                          (context, index) => SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final dish = dishes[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(child: DishCard(dish: dish)),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
