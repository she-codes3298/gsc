import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../common/app_drawer.dart';
import '../../common/bottom_nav.dart';
import '../../common/dashboard_card.dart';
import '../../common/translatable_text.dart';
import '../../common/language_selection_dialog.dart';
import '../community/community_page.dart';
import '../Teams/teams_page.dart';
import '../inventory/inventory_page.dart';
import '../settings/settings_page.dart';
import 'disaster_details_page.dart';
import 'flood_details_page.dart';

import 'package:gsc/services/translation_service.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  String activeDisaster = "Loading...";
  String activeDisasterType = "";

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            transform: GradientRotation(-40 * 3.14159 / 180),
            colors: [
              Color(0xFF87CEEB), // Sky Blue - matching inventory page
              Color(0xFF4682B4), // Steel Blue - matching inventory page
            ],
            stops: [0.3, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Stats Section (similar to inventory stats)
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white.withOpacity(0.95),
                child: ListTile(
                  title: const TranslatableText(
                    "Overview",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A324C),
                    ),
                  ),

                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3789BB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.dashboard,
                      color: Color(0xFF3789BB),
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Quick Actions Section
             /* const TranslatableText(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),*/

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    DashboardCard(
                      title: "Active Disasters",
                      count: activeDisaster,
                      icon: Icons.warning_amber_rounded,
                      onTap: activeDisasterType.isNotEmpty ? navigateToDisasterPage : null,
                    ),
                    DashboardCard(
                      title: "Add Refugee Camp",
                      count: "4",
                      icon: Icons.add_location_alt,
                      onTap: () {
                        Navigator.pushNamed(context, '/camp');
                      },
                    ),
                    DashboardCard(
                      title: "Ongoing SOS Alerts",
                      count: "12",
                      icon: Icons.sos_outlined,
                      onTap: () {
                        Navigator.pushNamed(context, '/sos_alerts');
                      },
                    ),
                    DashboardCard(
                      title: "Rescue Teams Deployed",
                      count: "5",
                      icon: Icons.groups_rounded,
                      onTap: () {
                        Navigator.pushNamed(context, '/deployed_teams');
                      },
                    ),
                    DashboardCard(
                      title: "Central Inventory",
                      count: "150 Items",
                      icon: Icons.inventory,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InventoryPage(),
                          ),
                        );
                      },
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A324C),
        title: const TranslatableText(
          "Central Government Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const LanguageSelectionDialog(),
              );
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
      body: _pages[_selectedIndex],
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3789BB),
        onPressed: () {
          Navigator.pushNamed(context, '/ai_chatbot');
        },
        child: Image.asset('assets/chatbot.png', width: 35, height: 35),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}