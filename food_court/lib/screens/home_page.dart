import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:food_court/screens/profile_screen.dart';
import 'package:provider/provider.dart';

import '../models/dish.dart';
import '../models/restaurant.dart';
import '../services/firebase_service.dart';
import '../screens/dish_detail_screen.dart';
import '../widgets/dish_card.dart';
import '../widgets/restaurant_card.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedCuisine = 'All';
  final _searchController = TextEditingController();

  final List<String> cuisines = [
    'All',
    'Italian',
    'Chinese',
    'Indian',
    'Mexican',
    'Japanese',
    'Bangladeshi',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDishDetail(Dish dish) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DishDetailScreen(dish: dish)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Gourmet Express',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.admin_panel_settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/admin_login'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ListView(
          children: [
            // 🔍 Search and Cuisine Filter
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search dishes or restaurants...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.grey[850],
                        value: _selectedCuisine,
                        items:
                            cuisines.map((c) {
                              return DropdownMenuItem<String>(
                                value: c,
                                child: Text(
                                  c,
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                        onChanged: (val) {
                          if (val != null)
                            setState(() => _selectedCuisine = val);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // 🍽️ Restaurants
            Text(
              'Featured Restaurants',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: StreamBuilder<QuerySnapshot>(
                stream: firebaseService.getRestaurants(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());

                  final docs = snapshot.data?.docs ?? [];
                  final restaurants =
                      docs
                          .map((doc) => Restaurant.fromFirestore(doc))
                          .where(
                            (r) =>
                                (_selectedCuisine == 'All' ||
                                    r.cuisine == _selectedCuisine) &&
                                r.title.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ),
                          )
                          .toList();

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: restaurants.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: RestaurantCard(restaurant: restaurants[i]),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 24),

            // 🍛 Dishes
            Text(
              'Popular Dishes',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('dishes').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                final docs = snapshot.data?.docs ?? [];
                final dishes =
                    docs
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

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: dishes.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: DishCard(dish: dishes[index]),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ❤️ Favorites placeholder
class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Favorites Coming Soon',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
