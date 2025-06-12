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
import 'earthquake_details_page.dart';
import 'flood_details_page.dart';
import 'package:gsc/models/disaster_event.dart';
import 'package:gsc/models/flood_prediction.dart';
import 'package:gsc/models/cyclone_prediction.dart';
import 'package:gsc/models/earthquake_prediction.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'cyclone_details_page.dart';
import 'package:gsc/services/translation_service.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  List<DisasterEvent> disasterEvents = [];
  // NEW: A state variable to hold the count of significant disasters.
  int _significantDisasterCount = 0;
  bool _isLoading = true;

  final List<Map<String, dynamic>> representativeLocations = [
    // Northern India (Earthquake Prone)
    {'name': 'Srinagar', 'lat': 34.0837, 'lon': 74.7973}, // Zone V
    {'name': 'Shimla', 'lat': 31.1048, 'lon': 77.1734}, // Zone IV
    {'name': 'Dehradun', 'lat': 30.3165, 'lon': 78.0322}, // Zone IV
    {'name': 'Delhi', 'lat': 28.7041, 'lon': 77.1025}, // Zone IV
    // North-Eastern India (High Earthquake & Flood Risk)
    {'name': 'Guwahati', 'lat': 26.1445, 'lon': 91.7362}, // Zone V
    {'name': 'Imphal', 'lat': 24.8170, 'lon': 93.9368}, // Zone V
    {'name': 'Agartala', 'lat': 23.8315, 'lon': 91.2868}, // Zone V
    {'name': 'Aizawl', 'lat': 23.7271, 'lon': 92.7176}, // Zone V
    // Eastern India (Flood & Cyclone Prone)
    {'name': 'Kolkata', 'lat': 22.5726, 'lon': 88.3639}, // Flood/Cyclone
    {'name': 'Bhubaneswar', 'lat': 20.2961, 'lon': 85.8245}, // Cyclone
    {'name': 'Puri', 'lat': 19.8135, 'lon': 85.8312}, // Cyclone
    {'name': 'Patna', 'lat': 25.5941, 'lon': 85.1376}, // Flood
    // Western India (Earthquake & Cyclone Prone)
    {'name': 'Mumbai', 'lat': 19.0760, 'lon': 72.8777}, // Cyclone/Flood
    {'name': 'Ahmedabad', 'lat': 23.0225, 'lon': 72.5714},
    {'name': 'Surat', 'lat': 21.1702, 'lon': 72.8311}, // Cyclone/Flood
    {'name': 'Bhuj', 'lat': 23.2423, 'lon': 69.6672}, // Zone V (Earthquake)
    {'name': 'Pune', 'lat': 18.5204, 'lon': 73.8567},

    // Southern India (Cyclone & Flood Prone)
    {'name': 'Chennai', 'lat': 13.0827, 'lon': 80.2707}, // Cyclone/Flood
    {'name': 'Visakhapatnam', 'lat': 17.6868, 'lon': 83.2185}, // Cyclone
    {'name': 'Kochi', 'lat': 9.9312, 'lon': 76.2673}, // Flood
    {'name': 'Hyderabad', 'lat': 17.3850, 'lon': 78.4867},
    {'name': 'Bengaluru', 'lat': 12.9716, 'lon': 77.5946},

    // Central India
    {'name': 'Nagpur', 'lat': 21.1458, 'lon': 79.0882},
    {'name': 'Bhopal', 'lat': 23.2599, 'lon': 77.4126},

    // Islands (High Seismic and Cyclone risk)
    {'name': 'Port Blair', 'lat': 11.6234, 'lon': 92.7265}, // Zone V
  ];

  @override
  void initState() {
    super.initState();
    fetchDisasterData();
  }

  /// Extracts the category number from a cyclone condition string.
  /// This is an assumption based on potential API responses like "Category 2".
  /// You should adapt this to your actual CyclonePrediction model if it's different.
  int _getCycloneCategory(String condition) {
    if (condition.toLowerCase().contains("category")) {
      try {
        var catNumberString =
            condition.toLowerCase().split("category")[1].trim().split(" ")[0];
        return int.tryParse(catNumberString) ?? 0;
      } catch (e) {
        print("Could not parse cyclone category: $e");
        return 0;
      }
    }
    return 0; // Return 0 if no category info is found
  }

  Future<void> fetchDisasterData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

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

    // Fetch Flood and Cyclone data
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

    // NEW: Logic to count only significant disasters based on your criteria.
    int significantCount = 0;
    for (var event in allFetchedDisasterData) {
      bool isSignificant = false;
      if (event.type == DisasterType.earthquake) {
        final data = event.predictionData as EarthquakePrediction;
        // *** FIX STARTS HERE ***
        // The error occurred because 'magnitude' is not a direct property of EarthquakePrediction.
        // It belongs to each 'HighRiskCity' inside the 'highRiskCities' list.
        // This new logic checks if ANY city in the list has a magnitude > 3.2.
        if (data.highRiskCities.any((city) => city.magnitude > 3.2)) {
          isSignificant = true;
        }
        // *** FIX ENDS HERE ***
      } else if (event.type == DisasterType.flood) {
        final data = event.predictionData as FloodPrediction;
        String risk = data.floodRisk.toLowerCase();
        if (risk == 'medium' || risk == 'high') {
          isSignificant = true;
        }
      } else if (event.type == DisasterType.cyclone) {
        final data = event.predictionData as CyclonePrediction;
        // NOTE: This uses the helper function to parse the category.
        // Adapt this if your model has a direct integer 'category' field.
        if (_getCycloneCategory(data.cycloneCondition) > 1) {
          isSignificant = true;
        }
      }

      if (isSignificant) {
        significantCount++;
      }
    }

    if (mounted) {
      setState(() {
        disasterEvents = allFetchedDisasterData;
        _significantDisasterCount =
            significantCount; // Update the significant count
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                final data = event.predictionData as EarthquakePrediction;
                // NOTE: Earthquake API might not return lat/lon.
                // You might need to add logic to get coordinates if you want to show it on the map.
                // For now, it will only appear in the list if it has no coordinates.
              }

              if (point != null) {
                return Marker(
                  width: 80.0,
                  height: 80.0,
                  point: point,
                  child: GestureDetector(
                    onTap: () {
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
              return null;
            })
            .whereType<Marker>()
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
        child: SafeArea(
          child:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                  : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DashboardCard(
                          title: "Disaster Overview",
                          // UPDATED: Display the count of significant events.
                          count:
                              "$_significantDisasterCount Significant Event(s)",
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
                        const SizedBox(height: 24),
                        const TranslatableText(
                          "Quick Actions",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DashboardCard(
                              title: "Add Refugee Camp",
                              count: "4",
                              icon: Icons.add_location_alt,
                              onTap: () {
                                Navigator.pushNamed(context, '/camp');
                              },
                            ),
                            const SizedBox(height: 12),
                            DashboardCard(
                              title: "Ongoing SOS Alerts",
                              count: "12",
                              icon: Icons.sos_outlined,
                              onTap: () {
                                Navigator.pushNamed(context, '/sos_alerts');
                              },
                            ),
                            const SizedBox(height: 12),
                            DashboardCard(
                              title: "Rescue Teams",
                              count: "5",
                              icon: Icons.groups_rounded,
                              onTap: () {
                                Navigator.pushNamed(context, '/deployed_teams');
                              },
                            ),
                            const SizedBox(height: 12),
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
      ),
    );
  }
}

// The rest of your file (DisasterOverviewPage, CentralDashboardPage, etc.)
// can remain the same as it correctly uses the full list of disasterEvents.
// ... (paste the rest of your original code here)

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
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                height: 300,
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
              const SizedBox(height: 20),
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
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
