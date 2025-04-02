import 'package:flutter/material.dart';
import '../../../auth/auth.dart'; // Import AuthService
import 'package:gsc/app/central/common/translatable_text.dart';


class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService =
        AuthService(); // Create an instance of AuthService

    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.grey[900]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(Icons.person, color: Colors.black, size: 35),
                ),
                const SizedBox(height: 10),
                const TranslatableText(
                  "Central Government",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),

          // ✅ Dashboard Button
          ListTile(
            leading: Icon(Icons.dashboard, color: Colors.white30),
            title: const TranslatableText(
              "Dashboard",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => _navigateTo(context, '/gov_dashboard'),
          ),

          // ✅ Community Button
          ListTile(
            leading: Icon(Icons.group, color: Colors.white30),
            title: const TranslatableText(
              "Community",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => _navigateTo(context, '/gov_community'),
          ),

          // ✅ Inventory Button
          ListTile(
            leading: Icon(Icons.storage, color: Colors.white30),
            title: const TranslatableText(
              "Inventory",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => _navigateTo(context, '/gov_inventory'),
          ),

          // ✅ Settings Button
          ListTile(
            leading: Icon(Icons.settings, color: Colors.white30),
            title: const TranslatableText(
              "Settings",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => _navigateTo(context, '/gov_settings'),
          ),

          // ✅ E-Sahyog AI Chatbot Button
          ListTile(
            leading: Image.asset(
              'assets/chatbot.png',
              width: 30,
              height: 30,
              color: Colors.white30,
            ),
            title: const TranslatableText(
              "E-Sahyog AI",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              _navigateTo(context, '/ai_chatbot');
            },
          ),

          const Divider(color: Colors.white30),

          // ✅ Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const TranslatableText("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              authService.signOut(context); // Call signOut method
            },
          ),
        ],
      ),
    );
  }

  // ✅ Function to build a Drawer item
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: TranslatableText(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        _navigateTo(context, route);
      },
    );
  }

  // ✅ FIX: Navigate correctly & close drawer properly
  void _navigateTo(BuildContext context, String route) {
    Navigator.pop(context); // Close the drawer

    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.popUntil(
        context,
        (route) => route.isFirst,
      ); // Remove all previous routes
      Navigator.pushReplacementNamed(
        context,
        route,
      ); // Navigate to the selected page
    }
  }
}