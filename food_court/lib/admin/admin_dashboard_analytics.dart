import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardAnalytics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        final orders = snapshot.data!.docs;

        int totalOrders = orders.length;
        double totalSales = 0;
        Map<String, int> dishCount = {};

        for (var order in orders) {
          final data = order.data() as Map<String, dynamic>;
          final dynamic quantityRaw = data['quantity'] ?? 1;
          final int quantity = quantityRaw is int ? quantityRaw : int.tryParse(quantityRaw.toString()) ?? 1;
          final dynamic priceRaw = data['price'] ?? 0.0;
          final double price = priceRaw is double ? priceRaw : double.tryParse(priceRaw.toString()) ?? 0.0;
          totalSales += (price * quantity);

          final foodId = data['foodId'] ?? '';
          dishCount[foodId] = (dishCount[foodId] ?? 0) + quantity;
        }

        String popularDish = dishCount.entries.isNotEmpty
            ? dishCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
            : 'N/A';

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Orders: $totalOrders', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text('Total Sales: \$${totalSales.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text('Most Popular Dish ID: $popularDish', style: TextStyle(fontSize: 18)),
            ],
          ),
        );
      },
    );
  }
}
