import 'package:flutter/material.dart';
import 'admin_dashboard_tab.dart';
import 'admin_restaurants_tab.dart';
import 'admin_dishes_tab.dart';
import 'admin_order_management.dart';
// Dishes tab with grid view, tap to show restaurants, and add button with multi-restaurant selection

class AdminMainScreen extends StatefulWidget {
  @override
  _AdminMainScreenState createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _tabs = <Widget>[
    AdminDashboardTab(),
    AdminRestaurantsTab(),
    AdminDishesTab(),
    AdminOrderManagement(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Panel'), backgroundColor: Colors.black),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Restaurants',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Dishes'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
        ],
      ),
    );
  }
}
