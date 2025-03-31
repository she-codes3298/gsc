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
import 'flood_details_page.dart';
import '../inventory/inventory_page.dart';

//import 'earthquake_details_page.dart';
//import 'cyclone_details_page.dart';

class DashboardView extends StatefulWidget {
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
      "Flood": 'https://water-level-model-bsbjxt7qdq-el.a.run.app/flood-assessments',
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
    }
    else if (activeDisasterType == "Flood") {
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
                    "onTap": index == 0 && activeDisasterType.isNotEmpty
                        ? navigateToDisasterPage
                        : null,
                  },
                  {
                    "title": "Central Inventory",
                    "count": "150 Items",
                    "icon": Icons.storage,
                    "onTap": () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => InventoryPage()),
                      );
                    },
                  },
                  {
                    "title": "Ongoing SOS Alerts",
                    "count": "12",
                    "icon": Icons.sos,
                    "onTap": null, // Keep disabled for now
                  },
                  {
                    "title": "Rescue Teams Deployed",
                    "count": "30",
                    "icon": Icons.people,
                    "onTap": null, // Keep disabled for now
                  },
                ];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InventoryPage()),
                    );
                  },
                  child: DashboardCard(
                    title: cardData[index]["title"],
                    count: cardData[index]["count"],
                    icon: cardData[index]["icon"],
                  ),
                );

              },
            ),

            const SizedBox(height: 20),
            // Add Refugee Camp Button
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/camp');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color.fromARGB(
                      255,
                      124,
                      138,
                      163,
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Add Refugee Camp",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Dashboard View (Now Fixed)
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

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
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 20), // ✅ Adds spacing to prevent overflow

              // ✅ NEW BUTTON: View Active SOS Alerts
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/sos_alerts'); // ✅ Navigates to SOS Alerts Page
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.red, // 🔴 SOS Button Color
                      elevation: 5,
                    ),
                    child: const Text(
                      "View Active SOS Alerts",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10), // ✅ Space between buttons

              // ✅ Existing Button: Add Refugee Camp (UNCHANGED)
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/camp');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color.fromARGB(
                        255,
                        124,
                        138,
                        163,
                      ), // ✅ Matches theme
                      elevation: 5,
                    ),
                    child: const Text(
                      "Add Refugee Camp",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
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
