import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gsc/models/disaster_event.dart'; // Assuming this will be needed
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gsc/models/flood_prediction.dart';
import 'package:gsc/models/cyclone_prediction.dart';
import 'package:gsc/models/earthquake_prediction.dart';
// Potentially details pages if navigation is added from here
// import 'earthquake_details_page.dart';
// import 'flood_details_page.dart';
// import 'cyclone_details_page.dart';

class ActiveDisastersMapPage extends StatefulWidget {
  const ActiveDisastersMapPage({Key? key}) : super(key: key);

  @override
  _ActiveDisastersMapPageState createState() => _ActiveDisastersMapPageState();
}

class _ActiveDisastersMapPageState extends State<ActiveDisastersMapPage> {
  List<DisasterEvent> _disasterEvents = []; // To store fetched disaster data
  bool _isLoading = true;

  final List<Map<String, dynamic>> representativeLocations = [
    // India
    {'name': 'Delhi', 'lat': 28.7041, 'lon': 77.1025, 'country': 'India'},
    {'name': 'Mumbai', 'lat': 19.0760, 'lon': 72.8777, 'country': 'India'},
    {'name': 'Kolkata', 'lat': 22.5726, 'lon': 88.3639, 'country': 'India'},
    {'name': 'Chennai', 'lat': 13.0827, 'lon': 80.2707, 'country': 'India'},
    {'name': 'Bengaluru', 'lat': 12.9716, 'lon': 77.5946, 'country': 'India'},
    {'name': 'Hyderabad', 'lat': 17.3850, 'lon': 78.4867, 'country': 'India'},
    {'name': 'Ahmedabad', 'lat': 23.0225, 'lon': 72.5714, 'country': 'India'},
    {'name': 'Pune', 'lat': 18.5204, 'lon': 73.8567, 'country': 'India'},
    {'name': 'Jaipur', 'lat': 26.9124, 'lon': 75.7873, 'country': 'India'},
    {'name': 'Lucknow', 'lat': 26.8467, 'lon': 80.9462, 'country': 'India'},
    {'name': 'Guwahati', 'lat': 26.1445, 'lon': 91.7362, 'country': 'India'}, // Northeast India
    {'name': 'Patna', 'lat': 25.5941, 'lon': 85.1376, 'country': 'India'}, // East India

    // Neighboring Countries
    {'name': 'Karachi', 'lat': 24.8607, 'lon': 67.0011, 'country': 'Pakistan'},
    {'name': 'Lahore', 'lat': 31.5204, 'lon': 74.3587, 'country': 'Pakistan'},
    {'name': 'Dhaka', 'lat': 23.8103, 'lon': 90.4125, 'country': 'Bangladesh'},
    {'name': 'Chittagong', 'lat': 22.3569, 'lon': 91.7832, 'country': 'Bangladesh'},
    {'name': 'Kathmandu', 'lat': 27.7172, 'lon': 85.3240, 'country': 'Nepal'},
    {'name': 'Colombo', 'lat': 6.9271, 'lon': 79.8612, 'country': 'Sri Lanka'},
    {'name': 'Yangon', 'lat': 16.8409, 'lon': 96.1735, 'country': 'Myanmar'},
    {'name': 'Thimphu', 'lat': 27.4728, 'lon': 89.6390, 'country': 'Bhutan'}
  ];

  Future<void> _fetchDisasterData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    List<DisasterEvent> allFetchedDisasterData = [];
    const newFloodApiUrl = 'https://flood-api-756506665902.us-central1.run.app/predict';
    const newCycloneApiUrl = 'https://cyclone-api-756506665902.asia-south1.run.app/predict';
    const newEarthquakeApiUrl = 'https://my-python-app-wwb655aqwa-uc.a.run.app/';

    // --- Earthquake (fetches once) ---
    try {
      final response = await http.get(Uri.parse(newEarthquakeApiUrl));
      if (response.statusCode == 200) {
        final earthquakeData = jsonDecode(response.body);
        final earthquakePrediction = EarthquakePrediction.fromJson(earthquakeData);
        allFetchedDisasterData.add(DisasterEvent(
          type: DisasterType.earthquake,
          predictionData: earthquakePrediction,
          timestamp: DateTime.now(),
        ));
      } else {
        print('Earthquake API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Earthquake API Exception: $e');
    }

    // --- Flood and Cyclone (iterate through representativeLocations) ---
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
            allFetchedDisasterData.add(DisasterEvent(
              type: DisasterType.flood,
              predictionData: prediction,
              timestamp: DateTime.now(),
            ));
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
              prediction.cycloneCondition.toLowerCase() != "no active cyclones detected") {
            allFetchedDisasterData.add(DisasterEvent(
              type: DisasterType.cyclone,
              predictionData: prediction,
              timestamp: DateTime.now(),
            ));
          }
        } else {
          print('Cyclone API Error for $cityName: ${cycloneResponse.statusCode}');
        }
      } catch (e) {
        print('Cyclone API Exception for $cityName: $e');
      }
    }

    if (mounted) {
      setState(() {
        _disasterEvents = allFetchedDisasterData;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDisasterData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Disasters Map'),
        // Potentially add back button or make it automatic
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 3, // Give more space to the map
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
                      // TODO: Add MarkerLayer for disasters
                      MarkerLayer(markers: _buildMarkers()),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2, // Space for the list and button
                  child: Column(
                    children: [
                      Expanded(
                        child: _disasterEvents.isEmpty
                            ? const Center(child: Text('No active disasters to display.'))
                            : ListView.builder(
                                itemCount: _disasterEvents.length,
                                itemBuilder: (context, index) {
                                  final event = _disasterEvents[index];
                                  String title = event.type.toString().split('.').last.toUpperCase();
                                  String location = event.locationSummary;
                                  String details = event.severitySummary;

                                  IconData iconData;
                                  Color iconColor;

                                  switch (event.type) {
                                    case DisasterType.flood:
                                      iconData = Icons.water_drop;
                                      iconColor = Colors.blue;
                                      break;
                                    case DisasterType.cyclone:
                                      iconData = Icons.cyclone;
                                      iconColor = Colors.orange;
                                      break;
                                    case DisasterType.earthquake:
                                      iconData = Icons.volcano;
                                      iconColor = Colors.brown;
                                      break;
                                    default:
                                      iconData = Icons.warning;
                                      iconColor = Colors.grey;
                                  }

                                  return Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: ListTile(
                                      leading: Icon(iconData, color: iconColor, size: 40),
                                      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text('Location: $location\nDetails: $details'),
                                      isThreeLine: true,
                                      // Optionally, add onTap to navigate to a specific detail page for this event
                                    ),
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement Raise Alert functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Raise Alert button pressed! (Not implemented yet)')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          child: const Text('Raise Alert', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // TODO: Implement _buildMarkers() method
  List<Marker> _buildMarkers() {
    if (_disasterEvents.isEmpty) return [];

    List<Marker> mapMarkers = _disasterEvents.map((event) {
      LatLng? point;
      Color markerColor = Colors.grey;
      IconData markerIcon = Icons.place;
      String eventTitle = "Disaster";

      if (event.type == DisasterType.flood) {
        final data = event.predictionData as FloodPrediction;
        point = LatLng(data.lat, data.lon);
        markerColor = Colors.blue;
        markerIcon = Icons.water_drop;
        eventTitle = "Flood: ${data.matchedDistrict}";
      } else if (event.type == DisasterType.cyclone) {
        final data = event.predictionData as CyclonePrediction;
        point = LatLng(data.location.latitude, data.location.longitude);
        markerColor = Colors.orange;
        markerIcon = Icons.cyclone;
        eventTitle = "Cyclone: ${data.location.district}";
      } else if (event.type == DisasterType.earthquake) {
        final data = event.predictionData as EarthquakePrediction;
        markerColor = Colors.brown;
        markerIcon = Icons.volcano; // Earthquake icon
        eventTitle = "Earthquake Risk";
        // For earthquakes, we might not have a single point from the current API structure for high_risk_cities.
        // We could try to geocode the first city, or place a generic marker.
        // For simplicity, if no specific lat/lon, this marker might not appear or appear at a default location.
        // This part needs careful handling based on how earthquake data should be visualized.
        // Let's assume for now we won't plot individual earthquake cities on this overview map to avoid clutter,
        // or we pick the first high-risk city if available and geocode it (complex for this step).
        // So, earthquake markers might be skipped if `point` remains null.
         if (data.highRiskCities.isNotEmpty) {
          // Attempt to use the first city as a representative point - this is a simplification
          // In a real app, you might geocode this city name to get LatLng
          // For now, we don't have lat/lon for earthquake cities directly from the model.
          // So, we'll only show a general indication or list them separately.
          // To make them appear on map, lat/lon would need to be added or geocoded.
          // For this iteration, marker will not be created if point is null.
           eventTitle = "Earthquake: ${data.highRiskCities.first.city}";
         }
      }

      if (point != null) {
        return Marker(
          width: 80.0,
          height: 80.0,
          point: point,
          child: Tooltip(
            message: eventTitle,
            child: Icon(markerIcon, color: markerColor, size: 30.0),
          ),
          // Optionally, add onTap to show details or navigate
        );
      }
      return null;
    }).where((marker) => marker != null).cast<Marker>().toList();
    return mapMarkers;
  }
}
