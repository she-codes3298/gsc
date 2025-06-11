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
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A324C), // Dark blue - matching inventory page
              Color(0xFF3789BB), // Medium blue - matching inventory page
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A324C).withOpacity(0.9),
                    const Color(0xFF4682B4).withOpacity(0.9),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(Icons.person, color: Color(0xFF1A324C), size: 35),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const TranslatableText(
                    "Central Government",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Dashboard Button
            _buildDrawerItem(
              context,
              icon: Icons.dashboard,
              label: "Dashboard",
              route: '/gov_dashboard',
            ),

            // Community Button
            _buildDrawerItem(
              context,
              icon: Icons.group,
              label: "Community",
              route: '/gov_community',
            ),

            // Inventory Button
            _buildDrawerItem(
              context,
              icon: Icons.storage,
              label: "Inventory",
              route: '/gov_inventory',
            ),

            // Settings Button
            _buildDrawerItem(
              context,
              icon: Icons.settings,
              label: "Settings",
              route: '/gov_settings',
            ),

            // E-Sahyog AI Chatbot Button
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/chatbot.png',
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
              ),
              title: const TranslatableText(
                "E-Sahyog AI",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                _navigateTo(context, '/ai_chatbot');
              },
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Divider(
                color: Colors.white24,
                thickness: 1,
              ),
            ),

            // Logout Button
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout, color: Colors.red, size: 24),
              ),
              title: const TranslatableText(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                authService.signOut(context); // Call signOut method
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function to build a Drawer item with consistent styling
  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String route,
      }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
      title: TranslatableText(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        _navigateTo(context, route);
      },
    );
  }

  // Navigate correctly & close drawer properly
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