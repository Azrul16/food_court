import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  final List<String> dummyOrders = [
    'Order #1 - Yorkshire Lamb Patties',
    'Order #2 - Lobster Thermidor',
    'Order #3 - Chicken Madeira',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: ListView.builder(
        itemCount: dummyOrders.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(dummyOrders[index]),
            leading: Icon(Icons.receipt),
          );
        },
      ),
    );
  }
}
