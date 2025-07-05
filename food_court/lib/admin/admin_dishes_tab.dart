import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dish.dart';
import '../models/restaurant.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/restaurant_card.dart';

class AdminDishesTab extends StatefulWidget {
  @override
  _AdminDishesTabState createState() => _AdminDishesTabState();
}

class _AdminDishesTabState extends State<AdminDishesTab> {
  Dish? _selectedDish;

  void _selectDish(Dish dish) {
    setState(() {
      _selectedDish = dish;
    });
  }

  void _showAddDishDialog() {
    showDialog(
      context: context,
      builder:
          (context) => _AddDishDialog(
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
                  FirebaseFirestore.instance.collection('dishes').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                final dishes =
                    snapshot.data!.docs
                        .map((doc) => Dish.fromFirestore(doc))
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
                    itemCount: dishes.length,
                    itemBuilder: (context, index) {
                      final dish = dishes[index];
                      return GestureDetector(
                        onTap: () => _selectDish(dish),
                        child: Card(
                          color:
                              _selectedDish?.id == dish.id
                                  ? Colors.blue[800]
                                  : Colors.grey[900],
                          child: Center(
                            child: Text(
                              dish.title,
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
          if (_selectedDish != null)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('restaurants')
                        .where('id', whereIn: [_selectedDish!.restaurantId])
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  final restaurants =
                      snapshot.data!.docs
                          .map((doc) => Restaurant.fromFirestore(doc))
                          .toList();
                  if (restaurants.isEmpty) {
                    return Center(
                      child: Text(
                        'No restaurants found for this dish',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  }
                  return AnimationLimiter(
                    child: ListView.builder(
                      itemCount: restaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = restaurants[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDishDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[800],
      ),
    );
  }
}

class _AddDishDialog extends StatefulWidget {
  final VoidCallback onAdded;

  _AddDishDialog({required this.onAdded});

  @override
  __AddDishDialogState createState() => __AddDishDialogState();
}

class __AddDishDialogState extends State<_AddDishDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _slogan = '';
  double _price = 0.0;
  String _image = '';
  String _cuisine = '';
  List<String> _selectedRestaurantIds = [];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRestaurantIds.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Select at least one restaurant')));
      return;
    }
    _formKey.currentState!.save();

    try {
      await FirebaseFirestore.instance.collection('dishes').add({
        'title': _title,
        'slogan': _slogan,
        'price': _price,
        'image': _image,
        'cuisine': _cuisine,
        'restaurantIds': _selectedRestaurantIds,
      });
      widget.onAdded();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add dish: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Dish'),
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
              TextFormField(
                decoration: InputDecoration(labelText: 'Slogan'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter slogan' : null,
                onSaved: (value) => _slogan = value!.trim(),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter price';
                  if (double.tryParse(value) == null)
                    return 'Enter valid number';
                  return null;
                },
                onSaved: (value) => _price = double.parse(value!),
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
              SizedBox(height: 12),
              Text(
                'Select Restaurants',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('restaurants')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final restaurants =
                      snapshot.data!.docs
                          .map((doc) => Restaurant.fromFirestore(doc))
                          .toList();
                  return Column(
                    children:
                        restaurants.map((restaurant) {
                          return CheckboxListTile(
                            title: Text(restaurant.title),
                            value: _selectedRestaurantIds.contains(
                              restaurant.id,
                            ),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedRestaurantIds.add(restaurant.id);
                                } else {
                                  _selectedRestaurantIds.remove(restaurant.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [ElevatedButton(onPressed: _submit, child: Text('Submit'))],
    );
  }
}
