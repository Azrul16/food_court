import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant.dart';
import '../models/dish.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/dish_card.dart';

class AdminRestaurantsTab extends StatefulWidget {
  @override
  _AdminRestaurantsTabState createState() => _AdminRestaurantsTabState();
}

class _AdminRestaurantsTabState extends State<AdminRestaurantsTab> {
  Restaurant? _selectedRestaurant;

  void _selectRestaurant(Restaurant restaurant) {
    setState(() {
      _selectedRestaurant = restaurant;
    });
  }

  void _showAddRestaurantDialog() {
    showDialog(
      context: context,
      builder:
          (context) => _AddRestaurantDialog(
            onAdded: () {
              Navigator.of(context).pop();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('restaurants')
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                final restaurants =
                    snapshot.data!.docs
                        .map((doc) => Restaurant.fromFirestore(doc))
                        .toList();
                return AnimationLimiter(
                  child: GridView.builder(
                    padding: EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];
                      return GestureDetector(
                        onTap: () => _selectRestaurant(restaurant),
                        child: Card(
                          color:
                              _selectedRestaurant?.id == restaurant.id
                                  ? Colors.blue[800]
                                  : Colors.grey[900],
                          child: Center(
                            child: Text(
                              restaurant.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (_selectedRestaurant != null)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('dishes')
                        .where(
                          'restaurantId',
                          isEqualTo: _selectedRestaurant!.id,
                        )
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  final dishes =
                      snapshot.data!.docs
                          .map((doc) => Dish.fromFirestore(doc))
                          .toList();
                  if (dishes.isEmpty) {
                    return Center(
                      child: Text(
                        'No dishes found for this restaurant',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  }
                  return AnimationLimiter(
                    child: ListView.builder(
                      itemCount: dishes.length,
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
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRestaurantDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[800],
      ),
    );
  }
}

class _AddRestaurantDialog extends StatefulWidget {
  final VoidCallback onAdded;

  _AddRestaurantDialog({required this.onAdded});

  @override
  __AddRestaurantDialogState createState() => __AddRestaurantDialogState();
}

class __AddRestaurantDialogState extends State<_AddRestaurantDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _cuisine = '';
  String _image = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      await FirebaseFirestore.instance.collection('restaurants').add({
        'title': _title,
        'cuisine': _cuisine,
        'image': _image,
      });
      widget.onAdded();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add restaurant: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Restaurant'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter title' : null,
                onSaved: (value) => _title = value!.trim(),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Cuisine'),
                items:
                    [
                      'Italian',
                      'Chinese',
                      'Indian',
                      'Mexican',
                      'American',
                      'Thai',
                      'Japanese',
                      'Bangladeshi',
                    ].map((cuisine) {
                      return DropdownMenuItem<String>(
                        value: cuisine,
                        child: Text(cuisine),
                      );
                    }).toList(),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Select a cuisine'
                            : null,
                onChanged: (value) {
                  setState(() {
                    _cuisine = value!;
                  });
                },
                value: _cuisine.isEmpty ? null : _cuisine,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Image URL'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter image URL'
                            : null,
                onSaved: (value) => _image = value!.trim(),
              ),
            ],
          ),
        ),
      ),
      actions: [ElevatedButton(onPressed: _submit, child: Text('Submit'))],
    );
  }
}
