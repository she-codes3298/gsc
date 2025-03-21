import 'dart:convert';
import 'package:flutter/material.dart';
import '../../common/app_drawer.dart';
import '../../common/bottom_nav.dart';
import '../../common/dashboard_card.dart';
import '../community/community_page.dart';
import '../inventory/inventory_page.dart';
import '../settings/settings_page.dart';
import 'disaster_details_page.dart';
import 'package:http/http.dart' as http;

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

// ✅ Dashboard View (Now Fixed)
class _DashboardViewState extends State<DashboardView> {
  String highRiskAreas = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchDisasterData();
  }

  Future<void> fetchDisasterData() async {
    final url = Uri.parse('https://my-python-app-wwb655aqwa-uc.a.run.app/');
    try {
      final response = await http.get(url);

      if (!mounted) return; // ✅ Prevent setState() on unmounted widget

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          highRiskAreas = data['high_risk_areas'] ?? "No data available";
        });
      } else {
        setState(() {
          highRiskAreas = "Error fetching data";
        });
      }
    } catch (e) {
      if (!mounted) return; // ✅ Prevent crash
      setState(() {
        highRiskAreas = "Failed to load data";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // ✅ Prevent unnecessary height expansion
          children: [
            GridView.builder(
              shrinkWrap: true, // ✅ Ensures GridView takes only required space
              physics: NeverScrollableScrollPhysics(), // ✅ Avoid nested scrolling issues
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.8,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                List<Map<String, dynamic>> cardData = [
                  {
                    "title": "Active Disasters",
                    "count": highRiskAreas,
                    "icon": Icons.warning,
                    "link": "https://my-python-app-wwb655aqwa-uc.a.run.app/"
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
                return GestureDetector(
                  onTap: index == 0
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DisasterDetailsPage(),
                      ),
                    );
                  }
                      : null,
                  child: DashboardCard(
                    title: cardData[index]["title"],
                    count: cardData[index]["count"],
                    icon: cardData[index]["icon"],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} // ✅ This was missing (Now Fixed)

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
              backgroundColor: Colors.white,
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
