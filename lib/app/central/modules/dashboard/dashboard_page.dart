import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../common/app_drawer.dart';
import '../../common/bottom_nav.dart';
import '../../common/dashboard_card.dart'; // Ensure this common widget is available
import '../../common/translatable_text.dart';
import '../../common/language_selection_dialog.dart';
import '../community/community_page.dart';
import '../Teams/teams_page.dart';
import '../inventory/inventory_page.dart';
import '../settings/settings_page.dart';
import 'earthquake_details_page.dart';
import 'flood_details_page.dart';
import 'package:gsc/models/disaster_event.dart'; // Ensure these models are defined
import 'package:gsc/models/flood_prediction.dart';
import 'package:gsc/models/cyclone_prediction.dart';
import 'package:gsc/models/earthquake_prediction.dart';
import 'package:flutter_map/flutter_map.dart'; // Ensure flutter_map is imported and configured
import 'package:latlong2/latlong.dart';
import 'cyclone_details_page.dart';
// import 'flood_details_page.dart'; // Already imported, good to keep it for FloodDetailsPage

import 'package:gsc/services/translation_service.dart'; // Ensure translation service is defined

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  List<DisasterEvent> disasterEvents = [];

  // Representative locations for fetching data
  final List<Map<String, dynamic>> representativeLocations = [
    {'name': 'Delhi', 'lat': 28.7041, 'lon': 77.1025},
    {'name': 'Mumbai', 'lat': 19.0760, 'lon': 72.8777},
    {'name': 'Kolkata', 'lat': 22.5726, 'lon': 88.3639},
    {'name': 'Chennai', 'lat': 13.0827, 'lon': 80.2707},
    {'name': 'Bengaluru', 'lat': 12.9716, 'lon': 77.5946},
    {'name': 'Hyderabad', 'lat': 17.3850, 'lon': 78.4867},
    {'name': 'Ahmedabad', 'lat': 23.0225, 'lon': 72.5714},
    {'name': 'Pune', 'lat': 18.5204, 'lon': 73.8567},
    {'name': 'Jaipur', 'lat': 26.9124, 'lon': 75.7873},
    {'name': 'Lucknow', 'lat': 26.8467, 'lon': 80.9462},
  ];

  @override
  void initState() {
    super.initState();
    // Fetch disaster data when the widget initializes
    fetchDisasterData();
  }

  // Asynchronously fetches disaster data from various APIs
  Future<void> fetchDisasterData() async {
    List<DisasterEvent> allFetchedDisasterData = [];
    const newFloodApiUrl =
        'https://flood-api-756506665902.us-central1.run.app/predict';
    const newCycloneApiUrl =
        'https://cyclone-api-756506665902.asia-south1.run.app/predict';
    const newEarthquakeApiUrl =
        'https://my-python-app-wwb655aqwa-uc.a.run.app/';

    // Fetch Earthquake data
    try {
      final response = await http.get(Uri.parse(newEarthquakeApiUrl));
      if (response.statusCode == 200) {
        final earthquakeData = jsonDecode(response.body);
        final earthquakePrediction = EarthquakePrediction.fromJson(
          earthquakeData,
        );
        allFetchedDisasterData.add(
          DisasterEvent(
            type: DisasterType.earthquake,
            predictionData: earthquakePrediction,
            timestamp: DateTime.now(),
          ),
        );
      } else {
        print('Earthquake API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Earthquake API Exception: $e');
    }

    // Fetch Flood and Cyclone data for each representative location
    for (var locData in representativeLocations) {
      final double lat = locData['lat'];
      final double lon = locData['lon'];
      final String cityName = locData['name'];

      // Flood API Call
      try {
        final floodResponse = await http.post(
          Uri.parse(newFloodApiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"lat": lat, "lon": lon}),
        );
        if (floodResponse.statusCode == 200) {
          final data = jsonDecode(floodResponse.body);
          final prediction = FloodPrediction.fromJson(data);
          if (prediction.floodRisk.toLowerCase() != "no flood") {
            allFetchedDisasterData.add(
              DisasterEvent(
                type: DisasterType.flood,
                predictionData: prediction,
                timestamp: DateTime.now(),
              ),
            );
          }
        } else {
          print('Flood API Error for $cityName: ${floodResponse.statusCode}');
        }
      } catch (e) {
        print('Flood API Exception for $cityName: $e');
      }

      // Cyclone API Call
      try {
        final cycloneResponse = await http.post(
          Uri.parse(newCycloneApiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"lat": lat, "lon": lon}),
        );
        if (cycloneResponse.statusCode == 200) {
          final data = jsonDecode(cycloneResponse.body);
          final prediction = CyclonePrediction.fromJson(data);
          if (prediction.cycloneCondition.toLowerCase() != "no cyclone" &&
              prediction.cycloneCondition.toLowerCase() !=
                  "no active cyclones detected") {
            allFetchedDisasterData.add(
              DisasterEvent(
                type: DisasterType.cyclone,
                predictionData: prediction,
                timestamp: DateTime.now(),
              ),
            );
          }
        } else {
          print(
            'Cyclone API Error for $cityName: ${cycloneResponse.statusCode}',
          );
        }
      } catch (e) {
        print('Cyclone API Exception for $cityName: $e');
      }
    }

    // Update the state with fetched disaster events if the widget is still mounted
    if (mounted) {
      setState(() {
        disasterEvents = allFetchedDisasterData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prepare markers for the map based on disaster events
    List<Marker> mapMarkers =
        disasterEvents
            .map((event) {
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
                markerColor = Colors.brown;
                markerIcon = Icons.volcano;
                // For earthquake, if LatLng is not available from API, marker won't be created
                // You might need to geocode city names if you want earthquake markers on the map
              }

              // Return a Marker widget if a valid point is available
              if (point != null) {
                return Marker(
                  width: 80.0,
                  height: 80.0,
                  point: point,
                  child: GestureDetector(
                    onTap: () {
                      // Handle tap on individual map markers
                      final eventData = event.predictionData;
                      if (event.type == DisasterType.cyclone &&
                          eventData is CyclonePrediction) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CycloneDetailsPage(
                                  cyclonePrediction: eventData,
                                ),
                          ),
                        );
                      } else if (event.type == DisasterType.flood &&
                          eventData is FloodPrediction) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => FloodDetailsPage(
                                  floodPrediction: eventData,
                                ),
                          ),
                        );
                      } else if (event.type == DisasterType.earthquake &&
                          eventData is EarthquakePrediction) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EarthquakeDetailsPage(
                                  earthquakePrediction: eventData,
                                ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "No details page available for this map marker.",
                            ),
                          ),
                        );
                      }
                    },
                    child: Tooltip(
                      message:
                          "${event.type.toString().split('.').last}: ${event.locationSummary}",
                      child: Icon(
                        markerIcon,
                        color: markerColor,
                        size: 40.0,
                        semanticLabel:
                            "${event.type.toString().split('.').last} marker",
                      ),
                    ),
                  ),
                );
              }
              return null; // Filter out null markers
            })
            .where((marker) => marker != null)
            .cast<Marker>()
            .toList();

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
          // Makes the entire content scrollable
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 'Disaster Overview' card using DashboardCard
              // Tapping this card will navigate to a new page with map and details
              DashboardCard(
                title: "Disaster Overview",
                count: "${disasterEvents.length} Active Event(s)",
                icon: Icons.map_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DisasterOverviewPage(
                            disasterEvents: disasterEvents,
                            mapMarkers: mapMarkers,
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Disaster Cards List Section (These are the existing individual disaster cards)
              // This ListView is now separate from the main map view
              const TranslatableText(
                "Current Disaster Alerts",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap:
                    true, // Prevents ListView from taking infinite height
                physics:
                    const NeverScrollableScrollPhysics(), // Disables internal scrolling for ListView
                itemCount: disasterEvents.length,
                itemBuilder: (context, index) {
                  final event = disasterEvents[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 0,
                    ),
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
                              color:
                                  event.type == DisasterType.flood
                                      ? Colors.blue.shade700
                                      : event.type == DisasterType.cyclone
                                      ? Colors.orange.shade700
                                      : event.type == DisasterType.earthquake
                                      ? Colors.brown.shade700
                                      : Colors.black,
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
                                  final eventData = event.predictionData;
                                  if (event.type == DisasterType.cyclone &&
                                      eventData is CyclonePrediction) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => CycloneDetailsPage(
                                              cyclonePrediction: eventData,
                                            ),
                                      ),
                                    );
                                  } else if (event.type == DisasterType.flood &&
                                      eventData is FloodPrediction) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => FloodDetailsPage(
                                              floodPrediction: eventData,
                                            ),
                                      ),
                                    );
                                  } else if (event.type ==
                                          DisasterType.earthquake &&
                                      eventData is EarthquakePrediction) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => EarthquakeDetailsPage(
                                              earthquakePrediction: eventData,
                                            ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Details page for this disaster type not implemented or data mismatch.",
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const TranslatableText("View Details"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement raise alert functionality
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
              const SizedBox(height: 10),

              // Quick Actions GridView
              const TranslatableText(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95, // Adjusted for better vertical spacing
                shrinkWrap:
                    true, // Prevents GridView from taking infinite height
                physics:
                    const NeverScrollableScrollPhysics(), // Disables internal scrolling for GridView
                children: [
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
                    title: "Rescue Teams",
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
            ],
          ),
        ),
      ),
    );
  }
}

// New Page to display Map and Disaster Details when "Disaster Overview" is tapped
class DisasterOverviewPage extends StatelessWidget {
  final List<DisasterEvent> disasterEvents;
  final List<Marker> mapMarkers;

  const DisasterOverviewPage({
    Key? key,
    required this.disasterEvents,
    required this.mapMarkers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TranslatableText("Disaster Overview Details"),
        backgroundColor: const Color(0xFF1A324C),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Set back button color
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ), // Set title text color
      ),
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
          // Make the content of this page scrollable
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map Section (from original DashboardView)
              const TranslatableText(
                "Disaster Map",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300, // Adjust height as needed
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: FlutterMap(
                    options: const MapOptions(
                      initialCenter: LatLng(
                        20.5937,
                        78.9629,
                      ), // Center of India
                      initialZoom: 4.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(markers: mapMarkers),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20), // Add more spacing
              // Disaster Details List (from original DashboardView)
              const TranslatableText(
                "All Active Disaster Events",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap:
                    true, // Crucial for ListView inside SingleChildScrollView
                physics:
                    const NeverScrollableScrollPhysics(), // Disables internal scrolling
                itemCount: disasterEvents.length,
                itemBuilder: (context, index) {
                  final event = disasterEvents[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 0,
                    ),
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
                              color:
                                  event.type == DisasterType.flood
                                      ? Colors.blue.shade700
                                      : event.type == DisasterType.cyclone
                                      ? Colors.orange.shade700
                                      : event.type == DisasterType.earthquake
                                      ? Colors.brown.shade700
                                      : Colors.black,
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
                                  final eventData = event.predictionData;
                                  if (event.type == DisasterType.cyclone &&
                                      eventData is CyclonePrediction) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => CycloneDetailsPage(
                                              cyclonePrediction: eventData,
                                            ),
                                      ),
                                    );
                                  } else if (event.type == DisasterType.flood &&
                                      eventData is FloodPrediction) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => FloodDetailsPage(
                                              floodPrediction: eventData,
                                            ),
                                      ),
                                    );
                                  } else if (event.type ==
                                          DisasterType.earthquake &&
                                      eventData is EarthquakePrediction) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => EarthquakeDetailsPage(
                                              earthquakePrediction: eventData,
                                            ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Details page for this disaster type not implemented or data mismatch.",
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const TranslatableText("View Details"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement raise alert functionality
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
            ],
          ),
        ),
      ),
    );
  }
}

// Main Dashboard Page (remains largely unchanged)
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
