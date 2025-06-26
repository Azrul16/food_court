import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all restaurants
  Stream<QuerySnapshot> getRestaurants() {
    return _firestore.collection('restaurants').snapshots();
  }

  // Get dishes by restaurant
  Stream<QuerySnapshot> getDishesByRestaurant(String restaurantId) {
    return _firestore
        .collection('dishes')
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots();
  }

  // Get user orders
  Stream<QuerySnapshot> getUserOrders() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Get user profile
  Future<DocumentSnapshot> getUserProfile() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(userId).get();
  }
}
