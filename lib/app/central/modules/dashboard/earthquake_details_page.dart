import 'package:flutter/material.dart';
  // Import the function

class EarthquakeDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Earthquake Details")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, size: 80, color: Colors.red),
            SizedBox(height: 20),
            Text(
              "Earthquake Alert!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Details about the latest earthquake will be displayed here.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

