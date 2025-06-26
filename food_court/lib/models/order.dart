import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String userId;
  final String foodId;
  final int quantity;
  final String status;
  final Timestamp timestamp;

  Order({
    required this.id,
    required this.userId,
    required this.foodId,
    required this.quantity,
    required this.status,
    required this.timestamp,
  });

  factory Order.fromMap(Map<String, dynamic> data, String documentId) {
    return Order(
      id: documentId,
      userId: data['userId'] ?? '',
      foodId: data['foodId'] ?? '',
      quantity: data['quantity'] ?? 1,
      status: data['status'] ?? 'pending',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'foodId': foodId,
      'quantity': quantity,
      'status': status,
      'timestamp': timestamp,
    };
  }
}
