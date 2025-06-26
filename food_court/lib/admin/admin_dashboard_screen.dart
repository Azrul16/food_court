import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'admin_dashboard_analytics.dart';
import 'admin_order_management.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedSection = 'Dashboard';

  void _selectSection(String section) {
    setState(() {
      _selectedSection = section;
      Navigator.pop(context); // close drawer
    });
  }

  Widget _buildSectionContent() {
    switch (_selectedSection) {
      case 'Dashboard':
        return AdminDashboardAnalytics();
      case 'User Management':
        return Center(child: Text('User Management Screen'));
      case 'Restaurant Management':
        return Center(child: Text('Restaurant Management Screen'));
      case 'Add Restaurant':
        return Center(child: Text('Add Restaurant Screen'));
      case 'Add Food':
        return Center(child: Text('Add Food Screen'));
      case 'Category Management':
        return Center(child: Text('Category Management Screen'));
      case 'Menu Management':
        return Center(child: Text('Menu Management Screen'));
      case 'Order Management':
        return AdminOrderManagement();
      default:
        return Center(child: Text('Admin Dashboard Overview'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel - $_selectedSection'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Text(
                'Admin Panel',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: Text('Dashboard'),
              onTap: () => _selectSection('Dashboard'),
            ),
            ListTile(
              title: Text('User Management'),
              onTap: () => _selectSection('User Management'),
            ),
            ListTile(
              title: Text('Restaurant Management'),
              onTap: () => _selectSection('Restaurant Management'),
            ),
            ListTile(
              title: Text('Add Restaurant'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin_add_restaurant');
              },
            ),
            ListTile(
              title: Text('Add Food'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin_add_food');
              },
            ),
            ListTile(
              title: Text('Category Management'),
              onTap: () => _selectSection('Category Management'),
            ),
            ListTile(
              title: Text('Menu Management'),
              onTap: () => _selectSection('Menu Management'),
            ),
            ListTile(
              title: Text('Order Management'),
              onTap: () => _selectSection('Order Management'),
            ),
          ],
        ),
      ),
      body: _buildSectionContent(),
    );
  }
}
