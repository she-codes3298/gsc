import 'package:flutter/material.dart';
import '../../common/app_drawer.dart';
import '../../common/bottom_nav.dart';
import '../../common/dashboard_card.dart';
import '../community/community_page.dart';
import '../inventory/inventory_page.dart';
import '../settings/settings_page.dart';
import 'disaster_details_page.dart';


// ✅ Dashboard View (Now Fixed)
class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: screenHeight, // ✅ Ensures content fills screen
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Overview",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = (screenWidth < 600) ? 1 : 2;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(), // ✅ Fixes nested scroll issue
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: (screenWidth < 400) ? 2.5 : 1.8,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      List<Map<String, dynamic>> cardData = [
                        {
                          "title": "Active Disasters",
                          "count": "5",
                          "icon": Icons.warning,
                        },
                        {
                          "title": "Central Inventory",
                          "count": "150 Items",
                          "icon": Icons.storage,
                        },
                        {
                          "title": "Ongoing SOS Alerts",
                          "count": "12",
                          "icon": Icons.sos,
                        },
                        {
                          "title": "Rescue Teams Deployed",
                          "count": "30",
                          "icon": Icons.people,
                        },
                      ];
                      return DashboardCard(
                        title: cardData[index]["title"],
                        count: cardData[index]["count"],
                        icon: cardData[index]["icon"],
                        onTap: index == 0 // Only make "Active Disasters" tappable
                            ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DisasterDetailsPage(),
                            ),
                          );
                        }
                            : null, // Other cards remain non-tappable
                      );

                    },
                  );
                },
              ),

              const SizedBox(height: 20), // ✅ Adds spacing to prevent overflow
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Main Dashboard Page
class CentralDashboardPage extends StatefulWidget {
  const CentralDashboardPage({super.key});

  @override
  State<CentralDashboardPage> createState() => _CentralDashboardPageState();
}

class _CentralDashboardPageState extends State<CentralDashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardView(), // ✅ Dashboard correctly placed
    CommunityPage(),
    InventoryPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Central Government Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {
              // TODO: Implement Language Change Feature
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              // TODO: Implement Profile Page Navigation
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Stack(
        children: [
          _pages[_selectedIndex], // ✅ Dynamic content rendering
          // ✅ Floating AI Chatbot Button (Properly Placed)
          Positioned(
            bottom: 90, // ✅ Adjusted position to avoid bottom nav bar
            right: 16,
            child: FloatingActionButton(
              backgroundColor:
                  Colors.white, // ✅ Change if `accentColor` is missing
              onPressed: () {
                Navigator.pushNamed(context, '/ai_chatbot');
              },
              child: Image.asset('assets/chatbot.png', width: 35, height: 35),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
