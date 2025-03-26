import 'package:flutter/material.dart';
import '../../../auth/auth.dart'; // Import AuthService

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthService _authService =
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
                const Text(
                  "Central Government",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),

          // ✅ Dashboard Button
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            label: "Dashboard",
            route: '/gov_dashboard',
          ),

          // ✅ Community Button
          _buildDrawerItem(
            context,
            icon: Icons.group,
            label: "Community",
            route: '/gov_community',
          ),

          // ✅ Inventory Button
          _buildDrawerItem(
            context,
            icon: Icons.storage,
            label: "Inventory",
            route: '/gov_inventory',
          ),

          // ✅ Settings Button
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            label: "Settings",
            route: '/gov_settings',
          ),

          const Divider(color: Colors.white30),

          // ✅ E-Sahyog AI Chatbot Button
          ListTile(
            leading: Image.asset('assets/chatbot.png', width: 30, height: 30),
            title: const Text(
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
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              _authService.signOut(context); // Call signOut method
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
      title: Text(label, style: const TextStyle(color: Colors.white)),
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
