import 'package:flutter/material.dart';
import 'inventory_request_page.dart';
import 'inventory_update_page.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Central Inventory"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inventory Stats Section
            Card(
              color: Colors.blueGrey[100],
              child: const ListTile(
                title: Text("Total Items in Stock", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text("150 Items"), // Dummy data for now
                leading: Icon(Icons.storage, color: Colors.blueGrey),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions Section
            const Text("Quick Actions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              children: [
                _buildActionCard(
                  title: "Request Supplies",
                  icon: Icons.shopping_cart,
                  color: Colors.orange,
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
                  color: Colors.green,
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
