import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../common/app_drawer.dart';
import '../../common/bottom_nav.dart';
import '../../common/dashboard_card.dart';
import '../community/community_page.dart';
import '../Teams/teams_page.dart';
import '../inventory/inventory_page.dart';
import '../settings/settings_page.dart';
import 'disaster_details_page.dart';
import 'flood_details_page.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  String activeDisaster = "Loading...";
  String activeDisasterType = ""; // Stores the type of active disaster

  @override
  void initState() {
    super.initState();
    fetchDisasterData();
  }

  Future<void> fetchDisasterData() async {
    final urls = {
      "Earthquake": 'https://my-python-app-wwb655aqwa-uc.a.run.app/',
      "Flood":
          'https://water-level-model-bsbjxt7qdq-el.a.run.app/flood-assessments',
      "Cyclone": 'https://cyclone-app-vrdkju5xka-el.a.run.app',
    };

    try {
      for (var entry in urls.entries) {
        final response = await http.get(Uri.parse(entry.value));

        if (!mounted) return;

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (entry.key == "Earthquake" &&
              data.containsKey("high_risk_cities") &&
              data["high_risk_cities"].isNotEmpty) {
            setState(() {
              activeDisaster = "Earthquake";
              activeDisasterType = "Earthquake";
            });
            return;
          }

          if (entry.key == "Flood" &&
              data.containsKey("high_risk_states") &&
              data["high_risk_states"].isNotEmpty) {
            setState(() {
              activeDisaster = "Flood";
              activeDisasterType = "Flood";
            });
            return;
          }

          if (entry.key == "Cyclone" &&
              data.containsKey("current_data") &&
              data["current_data"]["status"] != "No active cyclones detected") {
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
    } else if (activeDisasterType == "Flood") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FloodDetailsPage()),
      );
    }
    // Uncomment when cyclone page is ready
    // else if (activeDisasterType == "Cyclone") {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => CycloneDetailsPage()),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: screenHeight, // Ensures content fills screen
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
                  int crossAxisCount =
                      (screenWidth < 500)
                          ? 1
                          : (screenWidth < 900)
                          ? 2
                          : 3;
                  double aspectRatio = (screenWidth / (crossAxisCount * 230))
                      .clamp(1.4, 2.3);

                  List<Map<String, dynamic>> cardData = [
                    {
                      "title": "Active Disasters",
                      "count": activeDisaster,
                      "icon": Icons.warning_amber_rounded,
                      "onTap":
                          activeDisasterType.isNotEmpty
                              ? navigateToDisasterPage
                              : null,
                    },
                    {
                      "title": "Central Inventory",
                      "count": "150 Items",
                      "icon": Icons.inventory,
                      "onTap": () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InventoryPage(),
                          ),
                        );
                      },
                    },
                    {
                      "title": "Ongoing SOS Alerts",
                      "count": "12",
                      "icon": Icons.sos_outlined,
                      "onTap": () {
                        Navigator.pushNamed(context, '/sos_alerts');
                      },
                    },
                    {
                      "title": "Rescue Teams Deployed",
                      "count": "5",
                      "icon": Icons.groups_rounded,
                      "onTap": () {
                        Navigator.pushNamed(context, '/deployed_teams');
                      },
                    },
                    {
                      "title": "Add Refugee Camp",
                      "icon": Icons.add_location_alt,
                      "count": "4",
                      "onTap": () {
                        Navigator.pushNamed(context, '/camp');
                      },
                    },
                  ];

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: aspectRatio,
                    ),
                    itemCount: cardData.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: cardData[index]["onTap"],
                        child: DashboardCard(
                          title: cardData[index]["title"],
                          count: cardData[index]["count"],
                          icon: cardData[index]["icon"],
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// Main Dashboard Page
class CentralDashboardPage extends StatefulWidget {
  const CentralDashboardPage({Key? key}) : super(key: key);

  @override
  State<CentralDashboardPage> createState() => _CentralDashboardPageState();
}

class _CentralDashboardPageState extends State<CentralDashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardView(),
    CommunityPage(),
    const InventoryPage(),
    const SettingsPage(),
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
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          _pages[_selectedIndex],
          Positioned(
            bottom: 90,
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
