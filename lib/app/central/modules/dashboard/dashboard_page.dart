import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import '../../common/app_drawer.dart';
import '../../common/bottom_nav.dart';
import '../../common/dashboard_card.dart';
import '../community/community_page.dart';
import '../inventory/inventory_page.dart';
import '../settings/settings_page.dart';
import 'disaster_details_page.dart';

import 'earthquake_details_page.dart';
import 'flood_details_page.dart';
import 'cyclone_details_page.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>{
  String activeDisaster = "Loading...";
  String activeDisasterType = ""; // To track which disaster is active

  @override
  void initState() {
    super.initState();
    fetchDisasterData();
  }

  Future<void> fetchDisasterData() async {
  final urls = {
    "Earthquake": 'https://earthquake-app-wwb655aqwa-el.a.run.app',
    "Cyclone": 'https://cyclone-app-vrdkju5xka-el.a.run.app',
  };

  try {
    for (var entry in urls.entries) {
      final response = await http.get(Uri.parse(entry.value));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (entry.key == "Earthquake" && data.containsKey("high_risk_cities") && data["high_risk_cities"].isNotEmpty) {
          setState(() {
            activeDisaster = "Earthquake";
            activeDisasterType = "Earthquake";
          });
          return; // Stop checking further if an active disaster is found
        }

        if (entry.key == "Cyclone" && data.containsKey("current_data") && data["current_data"]["status"] != "No active cyclones detected") {
          setState(() {
            activeDisaster = "Cyclone";
            activeDisasterType = "Cyclone";
          });
          return;
        }
      }
    }

    // If no active disasters found
    setState(() {
      activeDisaster = "No active disasters";
      activeDisasterType = "";
    });

  } catch (e) {
    if (!mounted) return;
    setState(() {
      activeDisaster = "Failed to load data";
      activeDisasterType = "";
    });
  }
}


  void navigateToDisasterPage() {
    if (activeDisasterType == "Earthquake") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DisasterDetailsPage()),
      );
    }  else if (activeDisasterType == "Cyclone") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CycloneDetailsPage()),
      );
    }
  }
  Future<void> sendDisasterAlert(String city) async {
    final String apiUrl = "http://127.0.0.1:8000/send-disaster-alert/";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'city': city,
          'title': "🚨 Earthquake Alert!",
          'body': "An earthquake risk is detected in $city. Stay alert!",
        }),
      );

      if (response.statusCode == 200) {
        _showAlertDialog("Success", "Notification sent successfully!");
      } else {
        _showAlertDialog("Failed", "Error: ${response.body}");
      }
    } catch (e) {
      _showAlertDialog("Error", "Exception: $e");
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
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
                    "count": activeDisaster,
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

                return GestureDetector(
                  onTap: index == 0 && activeDisasterType.isNotEmpty
                      ? navigateToDisasterPage
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