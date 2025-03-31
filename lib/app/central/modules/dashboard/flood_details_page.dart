import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FloodDetailsPage extends StatefulWidget {
  @override
  _FloodDetailsPageState createState() => _FloodDetailsPageState();
}

class _FloodDetailsPageState extends State<FloodDetailsPage> {
  List<dynamic> highRiskStates = [];
  String additionalInsights = "";
  String readMoreUrl = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFloodDetails();
  }

  Future<void> fetchFloodDetails() async {
    final url = "https://water-level-model-bsbjxt7qdq-el.a.run.app/flood-assessments";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          highRiskStates = data["high_risk_states"];
          additionalInsights = data["additional_insights"];
          readMoreUrl = data["read_more_url"];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load flood details");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flood Risk Details"),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "High-Risk States:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: highRiskStates.length,
                      itemBuilder: (context, index) {
                        final stateData = highRiskStates[index];
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(stateData["state"],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                "Flood Risk Score: ${stateData["flood_risk_score"]}%"),
                            leading: Icon(Icons.warning, color: Colors.red),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Insights:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(additionalInsights, style: TextStyle(fontSize: 14)),
                  SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (readMoreUrl.isNotEmpty) {
                          // Open the URL for more details
                          // You may use url_launcher package here
                        }
                      },
                      child: Text("Read More"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

