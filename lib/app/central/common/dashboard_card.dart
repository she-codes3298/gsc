import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final VoidCallback? onTap; // ✅ Accepts tap callback

  const DashboardCard({
    Key? key,
    required this.title,
    required this.count,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // ✅ Wrap in GestureDetector for tap functionality
      onTap: onTap, // ✅ This now works!
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1), // Semi-transparent white for contrast
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              count,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
