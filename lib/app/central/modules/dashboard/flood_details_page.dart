import 'package:flutter/material.dart';

class FloodDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flood Details")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              "Flood Warning!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Details about the latest flood will be displayed here.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

