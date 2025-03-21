import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;

  DashboardCard({required this.title, required this.count, required this.icon});



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ Prevent overflow
        mainAxisAlignment: MainAxisAlignment.center, // ✅ Center content
        children: [
          Icon(icon, size: 30, color: Colors.red),
          SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            count,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
