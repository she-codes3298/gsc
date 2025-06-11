import 'package:flutter/material.dart';
import 'package:gsc/app/central/common/translatable_text.dart';
import 'package:gsc/services/translation_service.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: Color(0xFF3789BB), // Light blue for selected icons
      unselectedItemColor: Colors.white, // Light blue for unselected icons
      backgroundColor: Color(0xFF1A324C), // Navy blue background
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      selectedLabelStyle: TextStyle(color: Colors.white), // White for selected text
      unselectedLabelStyle: TextStyle(color: Colors.white), // White for unselected text
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: "Community"),
        BottomNavigationBarItem(icon: Icon(Icons.storage), label: "Inventory"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}