import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminDashboardTab extends StatefulWidget {
  @override
  _AdminDashboardTabState createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  int totalUsers = 0;
  int totalOrdersToday = 0;
  int totalOrdersMonth = 0;
  int totalOrdersYear = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final firestore = FirebaseFirestore.instance;

    // Fetch total users count
    final usersSnapshot = await firestore.collection('users').get();
    final usersCount = usersSnapshot.size;

    // Fetch orders and calculate counts for today, month, year
    final ordersSnapshot = await firestore.collection('orders').get();
    final now = DateTime.now();

    int ordersToday = 0;
    int ordersMonth = 0;
    int ordersYear = 0;

    for (var doc in ordersSnapshot.docs) {
      final data = doc.data();
      final timestamp = data['createdAt'] as Timestamp?;
      if (timestamp == null) continue;
      final orderDate = timestamp.toDate();

      if (orderDate.year == now.year) {
        ordersYear++;
        if (orderDate.month == now.month) {
          ordersMonth++;
          if (orderDate.day == now.day) {
            ordersToday++;
          }
        }
      }
    }

    setState(() {
      totalUsers = usersCount;
      totalOrdersToday = ordersToday;
      totalOrdersMonth = ordersMonth;
      totalOrdersYear = ordersYear;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            'Dashboard Analytics',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 32),
          _buildStatCard('Total Users', totalUsers.toString(), Colors.blueAccent),
          SizedBox(height: 20),
          _buildStatCard('Total Orders Today (${dateFormat.format(DateTime.now())})', totalOrdersToday.toString(), Colors.greenAccent),
          SizedBox(height: 20),
          _buildStatCard('Total Orders This Month', totalOrdersMonth.toString(), Colors.orangeAccent),
          SizedBox(height: 20),
          _buildStatCard('Total Orders This Year', totalOrdersYear.toString(), Colors.purpleAccent),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color accentColor) {
    return Card(
      color: Colors.grey[850],
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: accentColor,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
