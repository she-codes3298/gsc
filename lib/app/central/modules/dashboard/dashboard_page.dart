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
import 'earthquake_details_page.dart'; // Renamed from disaster_details_page.dart
import 'flood_details_page.dart';
import 'package:gsc/models/disaster_event.dart';
import 'package:gsc/models/flood_prediction.dart';
import 'package:gsc/models/cyclone_prediction.dart';
import 'package:gsc/models/earthquake_prediction.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'cyclone_details_page.dart'; // Import for navigation
import 'flood_details_page.dart'; // Import for FloodDetailsPage
import 'active_disasters_map_page.dart';
import 'package:gsc/services/disaster_service.dart'; // Import the DisasterService
import 'package:gsc/services/translation_service.dart';
import 'package:firebase_database/firebase_database.dart'; // Import Firebase
import 'package:gsc/main.dart'; // Import main.dart for firebaseDatabase instance

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

import 'package:provider/provider.dart'; // Import Provider

class _DashboardViewState extends State<DashboardView> {
  List<DisasterEvent> disasterEvents = [];
  late DisasterService _disasterService; // To be initialized from Provider
  bool _isLoading = true; // To manage loading state

  @override
  void initState() {
    super.initState();
    // _disasterService is not available here yet if using didChangeDependencies for init.
    // If fetching data in initState, it must be done carefully or via another method.
    // For simplicity with Provider, often didChangeDependencies is used for one-time setup
    // or a post-frame callback if context is needed immediately in initState.
    // Or, pass context to _loadDisasterData if called from initState.
    // Let's assume _loadDisasterData will be called from didChangeDependencies or similar.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize and load data here as Provider.of can be safely called.
    if (_isLoading) { // Only load if not already loaded (e.g. due to other dependency changes)
      _disasterService = Provider.of<DisasterService>(context, listen: false);
      _loadDisasterData();
    }
  }

  Future<void> _loadDisasterData() async {
    if (!mounted) return;
    // setState for _isLoading is already called before _loadDisasterData in common patterns,
    // but if not, ensure it's set at the start of the load.
    // Since _isLoading is true initially, and we call this once in didChangeDependencies,
    // we might not need to set _isLoading = true here again unless _loadDisasterData can be called multiple times.
    // For safety, let's ensure it:
    if (!_isLoading) { // If called again (e.g. refresh)
       setState(() { _isLoading = true; });
    }

    try {
      final fetchedEvents = await _disasterService.fetchAndFilterDisasterData();
      if (mounted) {
        setState(() {
          disasterEvents = fetchedEvents;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print("Error loading disaster data in DashboardView: $e");
      // Optionally, show a snackbar or error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prepare markers for the map
    List<Marker> mapMarkers = disasterEvents.map((event) {
      LatLng? point;
      Color markerColor = Colors.grey;
      IconData markerIcon = Icons.place;

      if (event.type == DisasterType.flood) {
        final data = event.predictionData as FloodPrediction;
        point = LatLng(data.lat, data.lon);
        markerColor = Colors.blue;
        markerIcon = Icons.water_drop;
      } else if (event.type == DisasterType.cyclone) {
        final data = event.predictionData as CyclonePrediction;
        point = LatLng(data.location.latitude, data.location.longitude);
        markerColor = Colors.orange;
        markerIcon = Icons.cyclone;
      } else if (event.type == DisasterType.earthquake) {
        // final data = event.predictionData as EarthquakePrediction;
        // Simplified: Earthquake markers are skipped if direct LatLng is not available.
        // A proper implementation would require geocoding city names.
        // For now, we can assign a generic icon and color but no point unless one is available.
        markerColor = Colors.brown;
        markerIcon = Icons.volcano;
        // If you have a representative LatLng for earthquakes, assign it to `point` here.
        // Otherwise, `point` remains null and the marker won't be built.
      }

      if (point != null) {
        return Marker(
          width: 80.0,
          height: 80.0,
          point: point,
          child: GestureDetector(
            onTap: () {
              final eventData = event.predictionData;
              if (event.type == DisasterType.cyclone && eventData is CyclonePrediction) {
                Navigator.push(
                  context, // Using the main page's context
                  MaterialPageRoute(builder: (context) => CycloneDetailsPage(cyclonePrediction: eventData)),
                );
              } else if (event.type == DisasterType.flood && eventData is FloodPrediction) {
                Navigator.push(
                  context, // Using the main page's context
                  MaterialPageRoute(builder: (context) => FloodDetailsPage(floodPrediction: eventData)),
                );
              } else if (event.type == DisasterType.earthquake && eventData is EarthquakePrediction) {
                // This case might not be hit by map markers if they are not created for earthquakes without direct LatLng
                Navigator.push(
                  context, // Using the main page's context
                  MaterialPageRoute(builder: (context) => EarthquakeDetailsPage(earthquakePrediction: eventData)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar( // Using main page's context for ScaffoldMessenger
                  SnackBar(content: Text("No details page available for this map marker.")),
                );
              }
            },
            child: Tooltip(
              message: "${event.type.toString().split('.').last}: ${event.locationSummary}",
              child: Icon(
                markerIcon,
                color: markerColor,
                size: 40.0,
                semanticLabel: "${event.type.toString().split('.').last} marker",
              ),
            ),
          ),
        );
      }
      return null; // Return null for events that can't be mapped
    }).where((marker) => marker != null).cast<Marker>().toList(); // Filter out nulls


    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            transform: GradientRotation(-40 * 3.14159 / 180),
            colors: [
              Color(0xFF87CEEB), // Sky Blue
              Color(0xFF4682B4), // Steel Blue
            ],
            stops: [0.3, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
              // Overview Card (Kept from original layout)
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/active_disasters_map');
                },
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white.withOpacity(0.95),
                  child: ListTile(
                    title: const TranslatableText(
                      "Disaster Overview", // Updated title
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
                        Icons.map_outlined, // Changed Icon
                        color: Color(0xFF3789BB),
                        size: 28,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // Important to keep the row compact
                      children: <Widget>[
                        Text(
                          "${disasterEvents.length} Active Event(s)",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD32F2F), // A crisis-related color
                          ),
                        ),
                        const SizedBox(width: 8), // Spacing between text and icon
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), // Added arrow icon
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Map Section
              SizedBox(
                height: 300, // Adjust height as needed
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(20.5937, 78.9629), // Center of India
                      initialZoom: 4.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(markers: mapMarkers),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Disaster Cards List Section
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: disasterEvents.length,
                  itemBuilder: (context, index) {
                    final event = disasterEvents[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0),
                       shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.type.toString().split('.').last.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: event.type == DisasterType.flood ? Colors.blue.shade700 :
                                       event.type == DisasterType.cyclone ? Colors.orange.shade700 :
                                       event.type == DisasterType.earthquake ? Colors.brown.shade700 :
                                       Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text("Location: ${event.locationSummary}"),
                            const SizedBox(height: 4),
                            Text("Details: ${event.severitySummary}"),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    final eventData = event.predictionData; // To make conditions cleaner
                                    if (event.type == DisasterType.cyclone && eventData is CyclonePrediction) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CycloneDetailsPage(cyclonePrediction: eventData),
                                        ),
                                      );
                                    } else if (event.type == DisasterType.flood && eventData is FloodPrediction) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FloodDetailsPage(floodPrediction: eventData),
                                        ),
                                      );
                                    } else if (event.type == DisasterType.earthquake && eventData is EarthquakePrediction) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => EarthquakeDetailsPage(earthquakePrediction: eventData)),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Details page for ${event.type.toString().split('.').last} not implemented or data mismatch.")),
                                      );
                                    }
                                  },
                                  child: const TranslatableText("View Details"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[200],
                                    foregroundColor: Colors.black87,
                                  )
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    final eventToAlert = disasterEvents[index];
                                    String disasterType = eventToAlert.type.toString().split('.').last;
                                    String riskSeverity = eventToAlert.severitySummary;
                                    String locationSummary = eventToAlert.locationSummary;
                                    String timestamp = DateTime.now().toIso8601String();
                                    double? latitude;
                                    double? longitude;

                                    if (eventToAlert.type == DisasterType.flood) {
                                      final data = eventToAlert.predictionData as FloodPrediction;
                                      latitude = data.lat;
                                      longitude = data.lon;
                                    } else if (eventToAlert.type == DisasterType.cyclone) {
                                      final data = eventToAlert.predictionData as CyclonePrediction;
                                      latitude = data.location.latitude;
                                      longitude = data.location.longitude;
                                    }
                                    // For earthquakes, lat/lon remain null as per subtask decision.

                                    final alertData = {
                                      'disasterType': disasterType,
                                      'riskSeverity': riskSeverity,
                                      'locationSummary': locationSummary,
                                      'latitude': latitude,
                                      'longitude': longitude,
                                      'timestamp': timestamp,
                                      'status': 'pending', // Default status
                                    };

                                    try {
                                      // Using the global firebaseDatabase instance from main.dart
                                      await firebaseDatabase.ref('raised_alerts').push().set(alertData);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Alert raised for $disasterType at $locationSummary')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error raising alert: $e')),
                                      );
                                      print('Error raising alert: $e');
                                    }
                                  },
                                  child: const TranslatableText("Raise Alert"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              // Display a message if no events are available after loading
              if (!_isLoading && disasterEvents.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "No active disaster events to display based on current filters.",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
               const SizedBox(height: 10), // Spacing before the GridView
              // Existing Quick Actions GridView (kept as per revised plan)
              const TranslatableText(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              // Removed Expanded from GridView. GridView will take its natural height.
              // If scrolling is needed for the whole page, the outer Column should be in a SingleChildScrollView.
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Note: The "Active Disasters" card is removed as per plan
                  DashboardCard(
                      title: "Add Refugee Camp",
                      count: "4", // Example count
                      icon: Icons.add_location_alt,
                      onTap: () {
                        Navigator.pushNamed(context, '/camp');
                      },
                    ),
                    DashboardCard(
                      title: "Ongoing SOS Alerts",
                      count: "12", // Example count
                      icon: Icons.sos_outlined,
                      onTap: () {
                        Navigator.pushNamed(context, '/sos_alerts');
                      },
                    ),
                    DashboardCard(
                      title: "Rescue Teams", // Simplified title
                      count: "5", // Example count
                      icon: Icons.groups_rounded,
                      onTap: () {
                        Navigator.pushNamed(context, '/deployed_teams');
                      },
                    ),
                    DashboardCard(
                      title: "Central Inventory",
                      count: "150 Items", // Example count
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
              ] // End of else block for _isLoading
            ],
            ),
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