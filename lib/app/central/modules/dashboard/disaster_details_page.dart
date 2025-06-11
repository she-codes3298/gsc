import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:gsc/app/central/common/translatable_text.dart';

class DisasterDetailsPage extends StatefulWidget {
  final String? url;

  const DisasterDetailsPage({Key? key, this.url}) : super(key: key);

  @override
  _DisasterDetailsPageState createState() => _DisasterDetailsPageState();
}

class _DisasterDetailsPageState extends State<DisasterDetailsPage> {
  List<Map<String, dynamic>> earthquakeData = [];
  bool isLoading = true;
  bool hasError = false;

  // Define custom colors
  static const Color navyBlue = Color(0xFF1A324C);
  static const Color lightBlue = Color(0xFF3789BB);
  static const Color gradientStart = Color(0xFF87B7E8);
  static const Color gradientEnd = Color(0xFF414C58);

  @override
  void initState() {
    super.initState();
    fetchEarthquakeData();
  }

  Future<void> fetchEarthquakeData() async {
    try {
      final response = await http.get(
        Uri.parse("https://my-python-app-wwb655aqwa-uc.a.run.app/"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> highRiskCities = data['high_risk_cities'] ?? [];

        List<Map<String, dynamic>> extractedData = highRiskCities.map((quake) {
          return {
            "city": quake["city"] ?? "Unknown",
            "state": quake["state"] ?? "Unknown",
            "magnitude": quake["magnitude"] ?? "N/A",
          };
        }).toList();

        setState(() {
          earthquakeData = extractedData;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TranslatableText(
          "Active Disasters",
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
            transform: GradientRotation(-40 * 3.14159 / 180), // -40 degrees in radians
            colors: [
              Color(0xFF87B7E8), // 80% opacity equivalent
              Color(0xFF414C58), // 100% opacity
            ],
            stops: [0.8, 1.0],
          ),
        ),
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(lightBlue),
          ),
        )
            : hasError
            ? const Center(
          child: TranslatableText(
            "Failed to load data",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: earthquakeData.length,
            itemBuilder: (context, index) {
              return _buildEarthquakeCard(earthquakeData[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEarthquakeCard(Map<String, dynamic> quake) {
    Color zoneColor = _getZoneColor(quake["magnitude"]);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        color: navyBlue.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: lightBlue.withOpacity(0.3), width: 1),
        ),
        elevation: 4,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          leading: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: lightBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.terrain,
              color: lightBlue,
              size: 28,
            ),
          ),
          title: TranslatableText(
            "${quake["city"]}, ${quake["state"]}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TranslatableText(
                  "🌍 Magnitude: ${quake["magnitude"]}",
                  style: TextStyle(
                    color: _getMagnitudeColor(quake["magnitude"]),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                TranslatableText(
                  "⏰ Time: ${quake["time"] ?? "N/A"}",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                TranslatableText(
                  "🌎 Depth: ${quake["depth"] ?? "N/A"} km",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          trailing: Container(
            decoration: BoxDecoration(
              color: lightBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(
                Icons.open_in_new,
                color: lightBlue,
                size: 24,
              ),
              onPressed: () => launchUrl(
                Uri.parse("https://riseq.seismo.gov.in/riseq/earthquake"),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Get color for magnitude text based on risk level
  Color _getMagnitudeColor(dynamic magnitude) {
    if (magnitude is num) {
      if (magnitude >= 5.5) {
        return Colors.red; // High risk
      } else if (magnitude >= 4.5) {
        return Colors.orange; // Moderate risk
      } else {
        return lightBlue; // Low risk - use theme color
      }
    }
    return Colors.white; // Default
  }

  // Determine the zone color based on magnitude (kept for potential future use)
  Color _getZoneColor(dynamic magnitude) {
    if (magnitude is num) {
      if (magnitude >= 5.5) {
        return Colors.red; // High risk
      } else if (magnitude >= 4.5) {
        return Colors.orange; // Moderate risk
      } else {
        return Colors.green; // Low risk
      }
    }
    return Colors.white; // Default
  }
}