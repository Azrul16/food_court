import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/restaurant.dart';
import '../models/dish.dart';
import '../widgets/dish_card.dart';
import '../widgets/restaurant_card.dart';

class RestaurantDishesScreen extends StatefulWidget {
  @override
  _RestaurantDishesScreenState createState() => _RestaurantDishesScreenState();
}

class _RestaurantDishesScreenState extends State<RestaurantDishesScreen> {
  Restaurant? _selectedRestaurant;

  void _selectRestaurant(Restaurant restaurant) {
    setState(() {
      _selectedRestaurant = restaurant;
    });
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AddDataDialog(
        selectedRestaurant: _selectedRestaurant,
        onAdded: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurants & Dishes'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // Restaurant list
          Container(
            width: 250,
            color: Colors.grey[900],
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final restaurants = snapshot.data!.docs
                    .map((doc) => Restaurant.fromFirestore(doc))
                    .toList();
                return ListView.builder(
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurants[index];
                    return ListTile(
                      title: Text(
                        restaurant.title,
                        style: TextStyle(color: Colors.white),
                      ),
                      selected: _selectedRestaurant?.id == restaurant.id,
                      selectedTileColor: Colors.blue[800]?.withOpacity(0.5),
                      onTap: () => _selectRestaurant(restaurant),
                    );
                  },
                );
              },
            ),
          ),
          // Dishes list
          Expanded(
            child: _selectedRestaurant == null
                ? Center(
                    child: Text(
                      'Select a restaurant to view dishes',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('dishes')
                        .where('restaurantId', isEqualTo: _selectedRestaurant!.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                      final dishes = snapshot.data!.docs
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
                                child: FadeInAnimation(
                                  child: DishCard(dish: dish),
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
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[800],
      ),
    );
  }
}

class AddDataDialog extends StatefulWidget {
  final Restaurant? selectedRestaurant;
  final VoidCallback onAdded;

  AddDataDialog({this.selectedRestaurant, required this.onAdded});

  @override
  _AddDataDialogState createState() => _AddDataDialogState();
}

class _AddDataDialogState extends State<AddDataDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isAddingRestaurant = false;

  // Restaurant fields
  String _restaurantTitle = '';
  String _restaurantCuisine = '';
  String _restaurantImage = '';

  // Dish fields
  String _dishTitle = '';
  String _dishSlogan = '';
  double _dishPrice = 0.0;
  String _dishImage = '';
  String _dishCuisine = '';

  @override
  void initState() {
    super.initState();
    if (widget.selectedRestaurant != null) {
      _dishCuisine = widget.selectedRestaurant!.cuisine;
    }
  }

  void _toggleAddMode() {
    setState(() {
      _isAddingRestaurant = !_isAddingRestaurant;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      if (_isAddingRestaurant) {
        // Add restaurant
        await FirebaseFirestore.instance.collection('restaurants').add({
          'title': _restaurantTitle,
          'cuisine': _restaurantCuisine,
          'image': _restaurantImage,
        });
      } else {
        // Add dish
        if (widget.selectedRestaurant == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Select a restaurant first')),
          );
          return;
        }
        await FirebaseFirestore.instance.collection('dishes').add({
          'restaurantId': widget.selectedRestaurant!.id,
          'title': _dishTitle,
          'slogan': _dishSlogan,
          'price': _dishPrice,
          'image': _dishImage,
          'cuisine': _dishCuisine,
        });
      }
      widget.onAdded();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isAddingRestaurant ? 'Add Restaurant' : 'Add Dish'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: _isAddingRestaurant ? _buildRestaurantForm() : _buildDishForm(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _toggleAddMode,
          child: Text(_isAddingRestaurant ? 'Add Dish Instead' : 'Add Restaurant Instead'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text('Submit'),
        ),
      ],
    );
  }

  Widget _buildRestaurantForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          decoration: InputDecoration(labelText: 'Title'),
          validator: (value) => value == null || value.isEmpty ? 'Enter title' : null,
          onSaved: (value) => _restaurantTitle = value!.trim(),
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Cuisine'),
          validator: (value) => value == null || value.isEmpty ? 'Enter cuisine' : null,
          onSaved: (value) => _restaurantCuisine = value!.trim(),
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Image URL'),
          validator: (value) => value == null || value.isEmpty ? 'Enter image URL' : null,
          onSaved: (value) => _restaurantImage = value!.trim(),
        ),
      ],
    );
  }

  Widget _buildDishForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          decoration: InputDecoration(labelText: 'Title'),
          validator: (value) => value == null || value.isEmpty ? 'Enter title' : null,
          onSaved: (value) => _dishTitle = value!.trim(),
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Slogan'),
          validator: (value) => value == null || value.isEmpty ? 'Enter slogan' : null,
          onSaved: (value) => _dishSlogan = value!.trim(),
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Price'),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Enter price';
            if (double.tryParse(value) == null) return 'Enter valid number';
            return null;
          },
          onSaved: (value) => _dishPrice = double.parse(value!),
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Image URL'),
          validator: (value) => value == null || value.isEmpty ? 'Enter image URL' : null,
          onSaved: (value) => _dishImage = value!.trim(),
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Cuisine'),
          validator: (value) => value == null || value.isEmpty ? 'Enter cuisine' : null,
          onSaved: (value) => _dishCuisine = value!.trim(),
          initialValue: _dishCuisine,
        ),
      ],
    );
  }
}
