import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void initState() {
    super.initState();
    fetchEarthquakeData();
  }

  Future<void> fetchEarthquakeData() async {
    try {
      final response = await http.get(
        Uri.parse("https://earthquake-app-wwb655aqwa-el.a.run.app/"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> highRiskCities = data['high_risk_cities'] ?? [];

        List<Map<String, dynamic>> extractedData = highRiskCities.map((quake) {
          return {
            "city": quake["city"] ?? "Unknown",
            "state": quake["state"] ?? "Unknown",
            "magnitude": quake["magnitude"] ?? "N/A",
            "time": quake["time"] ?? "N/A",  // Extracting time
            "depth": quake["depth"] ?? "N/A" // Extracting depth
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
        title: const Text("Active Disasters"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? const Center(
          child: Text("Failed to load data", style: TextStyle(color: Colors.white)))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: earthquakeData.length,
          itemBuilder: (context, index) {
            return _buildEarthquakeCard(earthquakeData[index]);
          },
        ),
      ),
    );
  }

  Widget _buildEarthquakeCard(Map<String, dynamic> quake) {
    // Safely parse magnitude as a double
    double magnitude = double.tryParse(quake["magnitude"]?.toString() ?? "") ?? 0.0;
    Color zoneColor = _getZoneColor(magnitude);

    return Card(
      color: zoneColor.withOpacity(0.3),  // Slightly more visible background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.terrain, color: zoneColor, size: 30),
        title: Text(
          "${quake["city"]}, ${quake["state"]}",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🌍 Magnitude: $magnitude",
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            Text("⏰ Time: ${quake["time"]}",
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            Text("🌎 Depth: ${quake["depth"]} km",
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new, color: Colors.white),
          onPressed: () async {
            final url = Uri.parse("https://riseq.seismo.gov.in/riseq/earthquake");
            if (await canLaunchUrl(url)) {
              launchUrl(url);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Could not open the link")),
              );
            }
          },
        ),
      ),
    );
  }

  // Determine the zone color based on magnitude
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
