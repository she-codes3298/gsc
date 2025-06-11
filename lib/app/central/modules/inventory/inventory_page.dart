import 'package:flutter/material.dart';
import 'inventory_request_page.dart';
import 'inventory_update_page.dart';
import 'vendor_registration_page.dart';
import 'vendor_list_page.dart';
import 'govt_e_commerce.dart';
import 'package:gsc/app/central/common/translatable_text.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TranslatableText(
          "Central Inventory",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A324C), // Match dashboard app bar
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            transform: GradientRotation(-40 * 3.14159 / 180), // -40 degrees in radians
            colors: [
              Color(0xFF87CEEB), // Sky Blue - lighter and more vibrant
              Color(0xFF4682B4), // Steel Blue - professional yet lighter
            ],
            stops: [0.3, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Inventory Stats Section
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white.withOpacity(0.95),
                child: ListTile(
                  title: const TranslatableText(
                    "Total Items in Stock",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A324C),
                    ),
                  ),
                  subtitle: const TranslatableText(
                    "150 Items",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF3789BB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3789BB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.storage,
                      color: Color(0xFF3789BB),
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Quick Actions Section
              const TranslatableText(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    _buildActionCard(
                      title: "Register Vendor",
                      icon: Icons.person_add,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF3789BB), Color(0xFF1A324C)],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VendorRegistrationPage(),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      title: "View Vendors",
                      icon: Icons.store,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4682B4), Color(0xFF3789BB)],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VendorListPage(),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      title: "Request Supplies",
                      icon: Icons.shopping_cart,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF87CEEB), Color(0xFF3789BB)],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InventoryRequestPage(
                            availableItems: [
                              {"name": "Water Bottles", "quantity": 100},
                              {"name": "Food Packets", "quantity": 200},
                              {"name": "Medical Kits", "quantity": 50},
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      title: "Update Stock",
                      icon: Icons.edit,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF3789BB), Color(0xFF4682B4)],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InventoryUpdatePage(
                            itemId: "123", // Replace with actual item ID
                            initialName: "Water Bottles",
                            initialQuantity: 50,
                          ),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      title: "E-commerce",
                      icon: Icons.shopping_bag,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A324C), Color(0xFF3789BB)],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EcommercePage(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TranslatableText(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}