import 'package:flutter/material.dart';
import 'package:gsc/models/flood_prediction.dart';
import 'package:gsc/app/central/common/translatable_text.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FloodDetailsPage extends StatelessWidget {
  final FloodPrediction floodPrediction;

  const FloodDetailsPage({Key? key, required this.floodPrediction}) : super(key: key);

  // Consistent styling colors
  static const Color navyBlue = Color(0xFF1A324C);
  static const Color lightBlue = Color(0xFF3789BB);
  static const Color gradientStart = Color(0xFF87B7E8);
  static const Color gradientEnd = Color(0xFF414C58);

  // Helper widget for detail rows (can be extracted to a common file later)
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

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
        return Colors.redAccent;
      case 'medium': // Assuming 'medium' might be a value
        return Colors.orangeAccent;
      case 'low':
        return Colors.greenAccent;
      default:
        return Colors.yellowAccent; // For unknown or other values
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TranslatableText(
          "Flood Details",
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
            colors: [gradientStart, gradientEnd],
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
                      "Risk: ${floodPrediction.floodRisk}",
                      style: TextStyle(
                        color: _getRiskColor(floodPrediction.floodRisk),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(context, "Matched District:", floodPrediction.matchedDistrict, icon: Icons.location_on),
                    _buildDetailRow(context, "Original District:", floodPrediction.originalDistrict, icon: Icons.location_history),
                    _buildDetailRow(context, "Latitude:", floodPrediction.lat.toStringAsFixed(4), icon: Icons.pin_drop),
                    _buildDetailRow(context, "Longitude:", floodPrediction.lon.toStringAsFixed(4), icon: Icons.pin_drop),
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
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(floodPrediction.lat, floodPrediction.lon),
                            initialZoom: 9.0, // Zoom level
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
                                  point: LatLng(floodPrediction.lat, floodPrediction.lon),
                                  child: Icon(
                                    Icons.water_drop,
                                    color: _getRiskColor(floodPrediction.floodRisk),
                                    size: 40.0,
                                    semanticLabel: "Flood Location",
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
            // Remove old UI elements related to highRiskStates, additionalInsights, readMoreUrl
          ],
        ),
      ),
    );
  }
}
