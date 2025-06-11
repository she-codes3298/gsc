import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gsc/models/disaster_event.dart'; // Assuming this will be needed
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gsc/models/flood_prediction.dart';
import 'package:gsc/models/cyclone_prediction.dart';
import 'package:gsc/models/earthquake_prediction.dart';
import 'package:gsc/services/disaster_service.dart'; // Import DisasterService
import 'package:firebase_database/firebase_database.dart'; // Import Firebase
import 'package:gsc/main.dart'; // Import main.dart for firebaseDatabase instance
// Potentially details pages if navigation is added from here
// import 'earthquake_details_page.dart';
// import 'flood_details_page.dart';
// import 'cyclone_details_page.dart';

class ActiveDisastersMapPage extends StatefulWidget {
  const ActiveDisastersMapPage({Key? key}) : super(key: key);

  @override
  _ActiveDisastersMapPageState createState() => _ActiveDisastersMapPageState();
}

import 'package:provider/provider.dart'; // Import Provider

class _ActiveDisastersMapPageState extends State<ActiveDisastersMapPage> {
  List<DisasterEvent> _disasterEvents = []; // To store fetched disaster data
  bool _isLoading = true;
  late DisasterService _disasterService; // To be initialized from Provider

  @override
  void initState() {
    super.initState();
    // Data loading moved to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) { // Only load if not already loaded
      _disasterService = Provider.of<DisasterService>(context, listen: false);
      _loadDataFromServer();
    }
  }

  Future<void> _loadDataFromServer() async { // Renamed from _fetchDisasterData
    if (!mounted) return;
    // Ensure _isLoading is true at the start of a load, if this can be called multiple times.
    // If called only once from didChangeDependencies (controlled by _isLoading flag), this might be redundant.
    // if (!_isLoading) { setState(() { _isLoading = true; }); }


    try {
      final fetchedEvents = await _disasterService.fetchAndFilterDisasterData();
      if (mounted) {
        setState(() {
          _disasterEvents = fetchedEvents;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print("Error loading disaster data in ActiveDisastersMapPage: $e");
      // Optionally, display an error message to the user on the map page
      // For example, by setting a flag and showing a Text widget.
    }
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
                                  String severityDetails = event.severitySummary; // Default severity

                                  IconData iconData;
                                  Color iconColor;

                                  switch (event.type) {
                                    case DisasterType.flood:
                                      iconData = Icons.water_drop;
                                      iconColor = Colors.blue;
                                      final data = event.predictionData as FloodPrediction;
                                      severityDetails = 'Risk: ${data.floodRisk}';
                                      break;
                                    case DisasterType.cyclone:
                                      iconData = Icons.cyclone;
                                      iconColor = Colors.orange;
                                      final data = event.predictionData as CyclonePrediction;
                                      severityDetails = 'Condition: ${data.cycloneCondition}';
                                      break;
                                    case DisasterType.earthquake:
                                      iconData = Icons.volcano;
                                      iconColor = Colors.brown;
                                      // severityDetails is already "Max Mag: X.X" from event.severitySummary
                                      break;
                                    default:
                                      iconData = Icons.warning;
                                      iconColor = Colors.grey;
                                  }

                                  return Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: Padding( // Added Padding for content within Card
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            leading: Icon(iconData, color: iconColor, size: 40),
                                            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                                            subtitle: Text('Location: $location\nDetails: $severityDetails'),
                                            isThreeLine: true,
                                            contentPadding: EdgeInsets.zero, // Remove ListTile's default padding
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () async {
                                                  final eventToAlert = _disasterEvents[index];
                                                  String disasterTypeStr = eventToAlert.type.toString().split('.').last;
                                                  String riskSev = eventToAlert.severitySummary;
                                                  String locSum = eventToAlert.locationSummary;
                                                  String timeStmp = DateTime.now().toIso8601String();
                                                  double? lat;
                                                  double? lon;

                                                  if (eventToAlert.type == DisasterType.flood) {
                                                    final data = eventToAlert.predictionData as FloodPrediction;
                                                    lat = data.lat;
                                                    lon = data.lon;
                                                  } else if (eventToAlert.type == DisasterType.cyclone) {
                                                    final data = eventToAlert.predictionData as CyclonePrediction;
                                                    lat = data.location.latitude;
                                                    lon = data.location.longitude;
                                                  }

                                                  final alertData = {
                                                    'disasterType': disasterTypeStr,
                                                    'riskSeverity': riskSev,
                                                    'locationSummary': locSum,
                                                    'latitude': lat,
                                                    'longitude': lon,
                                                    'timestamp': timeStmp,
                                                    'status': 'pending',
                                                  };

                                                  try {
                                                    await firebaseDatabase.ref('raised_alerts').push().set(alertData);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Alert raised for $disasterTypeStr at $locSum')),
                                                    );
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Error raising alert: $e')),
                                                    );
                                                    print('Error raising alert: $e');
                                                  }
                                                },
                                                child: const Text("Raise Alert"), // Consider using TranslatableText if needed
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
                      ),
                      // Generic "Raise Alert" button removed from here
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
      String tooltipMessage = "Disaster"; // Changed variable name for clarity

      if (event.type == DisasterType.flood) {
        final data = event.predictionData as FloodPrediction;
        point = LatLng(data.lat, data.lon);
        markerColor = Colors.blue;
        markerIcon = Icons.water_drop;
        tooltipMessage = "Flood: ${data.matchedDistrict} (Risk: ${data.floodRisk})";
      } else if (event.type == DisasterType.cyclone) {
        final data = event.predictionData as CyclonePrediction;
        point = LatLng(data.location.latitude, data.location.longitude);
        markerColor = Colors.orange;
        markerIcon = Icons.cyclone;
        tooltipMessage = "Cyclone: ${data.location.district} (Condition: ${data.cycloneCondition})";
      } else if (event.type == DisasterType.earthquake) {
        final data = event.predictionData as EarthquakePrediction;
        markerColor = Colors.brown;
        markerIcon = Icons.volcano; // Earthquake icon
        String cityDetails = data.highRiskCities.isNotEmpty
                              ? data.highRiskCities.first.city
                              : "Area";
        tooltipMessage = "Earthquake: $cityDetails (${event.severitySummary})";
        // For earthquakes, point is not set here as city LatLng is not directly available.
        // A geocoding step would be needed, or points for cities added to the model.
        // For now, earthquake markers might not appear unless point is derived elsewhere or defaults.
        // To ensure markers for earthquakes, we'd need a representative LatLng.
        // If we want to show a marker for the general region of the earthquake prediction (if available)
        // or for each high-risk city (if they had lat/lon), that would be an addition.
        // For now, if data.highRiskCities is not empty, we can try to use a placeholder like the map center
        // or skip marker creation if no specific point.
        // The current logic will skip marker if point is null.
        // This subtask is about tooltip, so we ensure the message is ready.
      }

      if (point != null) {
        return Marker(
          width: 80.0,
          height: 80.0,
          point: point,
          child: Tooltip(
            message: tooltipMessage, // Use the enhanced tooltip message
            child: Icon(markerIcon, color: markerColor, size: 30.0),
          ),
          // Optionally, add onTap to show details or navigate
        );
      }
      // For earthquakes, if we want to show markers for each high-risk city,
      // we would need to iterate through data.highRiskCities and geocode them,
      // or have their LatLng available in the model. That's beyond current scope.
      return null;
    }).where((marker) => marker != null).cast<Marker>().toList();
    return mapMarkers;
  }
}
