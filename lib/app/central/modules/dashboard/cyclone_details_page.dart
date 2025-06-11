import 'package:flutter/material.dart';
import 'package:gsc/models/cyclone_prediction.dart'; // Model for cyclone data
import 'package:gsc/app/central/common/translatable_text.dart'; // For translatable text
import 'package:flutter_map/flutter_map.dart'; // For map display
import 'package:latlong2/latlong.dart';         // For LatLng objects

class CycloneDetailsPage extends StatelessWidget {
  final CyclonePrediction cyclonePrediction;

  const CycloneDetailsPage({Key? key, required this.cyclonePrediction}) : super(key: key);

  // Define custom colors (consistent with other detail pages if possible)
  static const Color navyBlue = Color(0xFF1A324C);
  static const Color lightBlue = Color(0xFF3789BB);

  Widget _buildDetailRow(BuildContext context, String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: lightBlue, size: 20),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 2,
            child: TranslatableText(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Location loc = cyclonePrediction.location;
    final WeatherData weather = cyclonePrediction.weatherData;

    return Scaffold(
      appBar: AppBar(
        title: const TranslatableText(
          "Cyclone Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: navyBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF87B7E8), Color(0xFF414C58)],
            stops: [0.8, 1.0],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              color: navyBlue.withOpacity(0.85),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatableText(
                      cyclonePrediction.cycloneCondition.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.orangeAccent, // Highlight condition
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(context, "Timestamp (UTC):", cyclonePrediction.timestampUtc, icon: Icons.access_time),
                    _buildDetailRow(context, "District:", loc.district, icon: Icons.location_city),
                    _buildDetailRow(context, "Latitude:", loc.latitude.toStringAsFixed(4), icon: Icons.pin_drop),
                    _buildDetailRow(context, "Longitude:", loc.longitude.toStringAsFixed(4), icon: Icons.pin_drop),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: navyBlue.withOpacity(0.85),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TranslatableText(
                      "Weather Data",
                      style: TextStyle(color: lightBlue, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(color: lightBlue),
                    _buildDetailRow(context, "Wind (USA):", "${weather.usaWind} m/s", icon: Icons.air),
                    _buildDetailRow(context, "Pressure (USA):", "${weather.usaPres} hPa", icon: Icons.compress),
                    _buildDetailRow(context, "Storm Speed:", "${weather.stormSpeed} km/h", icon: Icons.speed), // Assuming km/h
                    _buildDetailRow(context, "Storm Direction:", "${weather.stormDir}°", icon: Icons.explore),
                    _buildDetailRow(context, "Month:", weather.month.toString(), icon: Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: navyBlue.withOpacity(0.85),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                    child: TranslatableText(
                      "Location Map",
                      style: TextStyle(color: lightBlue, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(color: lightBlue, indent: 16, endIndent: 16),
                  SizedBox(
                    height: 250, // Adjust height as needed
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Add padding around the map
                      child: ClipRRect( // Clip the map with rounded corners
                        borderRadius: BorderRadius.circular(8.0),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(loc.latitude, loc.longitude),
                            initialZoom: 8.0, // Zoom level for a more focused view
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: const ['a', 'b', 'c'],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  width: 80.0,
                                  height: 80.0,
                                  point: LatLng(loc.latitude, loc.longitude),
                                  child: const Icon(
                                    Icons.cyclone,
                                    color: Colors.orangeAccent,
                                    size: 40.0,
                                    semanticLabel: "Cyclone Location",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
