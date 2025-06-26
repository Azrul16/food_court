import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/restaurant.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Restaurant? _selectedRestaurant;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Order', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Please login to place orders',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Login', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Your Order', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Restaurant',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('restaurants')
                        .snapshots(),
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
                          .toList();
                  return ListView.builder(
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];
                      return Card(
                        color: Colors.grey[900],
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(restaurant.image),
                          ),
                          title: Text(
                            restaurant.title,
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            restaurant.cuisine,
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedRestaurant = restaurant;
                            });
                          },
                          selected: _selectedRestaurant?.id == restaurant.id,
                          selectedTileColor: Colors.blue[800]?.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side:
                                _selectedRestaurant?.id == restaurant.id
                                    ? BorderSide(color: Colors.blue, width: 2)
                                    : BorderSide.none,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isSubmitting ? Colors.blue[900] : Colors.blue[800],
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed:
                    _isSubmitting
                        ? null
                        : () async {
                          setState(() {
                            _isSubmitting = true;
                          });
                          if (_selectedRestaurant == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a restaurant'),
                              ),
                            );
                            return;
                          }

                          try {
                            final user = FirebaseAuth.instance.currentUser!;
                            final orderRef = await FirebaseFirestore.instance
                                .collection('orders')
                                .add({
                                  'userId': user.uid,
                                  'restaurantId': _selectedRestaurant!.id,
                                  'restaurantName': _selectedRestaurant!.title,
                                  'status': 'pending',
                                  'createdAt': FieldValue.serverTimestamp(),
                                  'items': [],
                                });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order placed successfully!'),
                              ),
                            );
                            Navigator.pop(context);
                          } catch (e) {
                            setState(() {
                              _isSubmitting = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error placing order: ${e.toString()}',
                                ),
                              ),
                            );
                          }
                        },
                child:
                    _isSubmitting
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text(
                          'Submit Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
