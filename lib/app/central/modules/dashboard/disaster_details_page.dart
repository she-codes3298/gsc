import 'package:flutter/material.dart';

class DisasterDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Active Disasters"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDisasterSection(
              context,
              title: "Earthquake",
              icon: Icons.terrain,
              color: Colors.redAccent,
              onTap: () {},
            ),
            _buildDisasterSection(
              context,
              title: "Cyclone",
              icon: Icons.waves,
              color: Colors.blueAccent,
              onTap: () {},
            ),
            _buildDisasterSection(
              context,
              title: "Flood",
              icon: Icons.water,
              color: Colors.lightBlue,
              onTap: () {},
            ),
            _buildDisasterSection(
              context,
              title: "Tsunami",
              icon: Icons.tsunami,
              color: Colors.deepPurpleAccent,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisasterSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: onTap,
      ),
    );
  }
}

