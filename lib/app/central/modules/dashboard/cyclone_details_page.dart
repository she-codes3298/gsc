import 'package:flutter/material.dart';

class CycloneDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cyclone Details")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.air, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text(
              "Cyclone Alert!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Details about the latest cyclone will be displayed here.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

