import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AdminAddFoodScreen extends StatefulWidget {
  @override
  _AdminAddFoodScreenState createState() => _AdminAddFoodScreenState();
}

class _AdminAddFoodScreenState extends State<AdminAddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedRestaurantId;
  String? _selectedCuisine;
  String _title = '';
  String _slogan = '';
  double _price = 0.0;
  String _image = '';
  final List<String> _cuisines = ['Italian', 'Chinese', 'Indian', 'Mexican', 'Japanese', 'Mediterranean'];
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedRestaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('foods').add({
        'restaurantId': _selectedRestaurantId,
        'title': _title,
        'slogan': _slogan,
        'price': _price,
        'image': _image,
        'cuisine': _selectedCuisine,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Food added successfully')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add food')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildImagePreview() {
    if (_image.isEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(Icons.image, size: 48, color: Colors.grey[700]),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: _image,
        height: 150,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[900],
          child: Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[900],
          child: Center(child: Icon(Icons.error, color: Colors.red)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Add Food', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Text(
                'Admin Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.list_alt),
              title: Text('View All Orders'),
              onTap: () {
                Navigator.pushNamed(context, '/admin_orders');
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Food'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : AnimationLimiter(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(
                          child: widget,
                        ),
                      ),
                      children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return CircularProgressIndicator();
                        final restaurants = snapshot.data!.docs;
                        return DropdownButtonFormField<String>(
                          dropdownColor: Colors.grey[900],
                          decoration: InputDecoration(
                            labelText: 'Select Restaurant',
                            labelStyle: TextStyle(color: Colors.grey[400]),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[800]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue[800]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[900],
                          ),
                          style: TextStyle(color: Colors.white),
                          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
                          items: restaurants
                              .map((doc) => DropdownMenuItem<String>(
                                    value: doc.id,
                                    child: Text(
                                      doc['title'],
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ))
                              .toList(),
                          value: _selectedRestaurantId,
                          onChanged: (value) {
                            setState(() {
                              _selectedRestaurantId = value;
                            });
                          },
                          validator: (value) => value == null ? 'Please select a restaurant' : null,
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[800]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[800]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[900],
                      ),
                      style: TextStyle(color: Colors.white),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter title' : null,
                      onSaved: (value) => _title = value!.trim(),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Slogan',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[800]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[800]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[900],
                      ),
                      style: TextStyle(color: Colors.white),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter slogan' : null,
                      onSaved: (value) => _slogan = value!.trim(),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Price',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[800]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[800]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[900],
                        prefixText: '\$ ',
                        prefixStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter price';
                        if (double.tryParse(value) == null) return 'Enter a valid number';
                        return null;
                      },
                      onSaved: (value) => _price = double.parse(value!),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Image URL',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[800]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[800]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[900],
                      ),
                      style: TextStyle(color: Colors.white),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter image URL' : null,
                      onSaved: (value) {
                        setState(() {
                          _image = value!.trim();
                        });
                      },
                      onChanged: (value) {
                        if (value.trim().isNotEmpty) {
                          setState(() {
                            _image = value.trim();
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    _buildImagePreview(),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.grey[900],
                      decoration: InputDecoration(
                        labelText: 'Cuisine',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[800]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[800]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[900],
                      ),
                      style: TextStyle(color: Colors.white),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
                      items: _cuisines
                          .map((cuisine) => DropdownMenuItem<String>(
                                value: cuisine,
                                child: Text(
                                  cuisine,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ))
                          .toList(),
                      value: _selectedCuisine,
                      onChanged: (value) {
                        setState(() {
                          _selectedCuisine = value;
                        });
                      },
                      validator: (value) => value == null ? 'Please select a cuisine' : null,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _submit,
                      child: Text(
                        'Add Food',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
