import 'package:flutter/material.dart';
import 'package:gsc/app/central/common/translatable_text.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          transform: GradientRotation(-40 * 3.14159 / 180),
          colors: [
            Color(0xFF87CEEB), // Sky Blue - matching other pages
            Color(0xFF4682B4), // Steel Blue - matching other pages
          ],
          stops: [0.3, 1.0],
        ),
      ),
      child: Center(
        child: TranslatableText("Settings", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}