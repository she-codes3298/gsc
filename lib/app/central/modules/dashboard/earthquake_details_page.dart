import 'package:flutter/material.dart';
import 'package:gsc/models/earthquake_prediction.dart';
import 'package:gsc/app/central/common/translatable_text.dart';
import 'package:url_launcher/url_launcher.dart'; // For the "Read More" link

class EarthquakeDetailsPage extends StatelessWidget {
  final EarthquakePrediction earthquakePrediction;

  const EarthquakeDetailsPage({Key? key, required this.earthquakePrediction}) : super(key: key);

  static const Color navyBlue = Color(0xFF1A324C);
  static const Color lightBlue = Color(0xFF3789BB);
  static const Color gradientStart = Color(0xFF87B7E8);
  static const Color gradientEnd = Color(0xFF414C58);

  Widget _buildCityRiskCard(BuildContext context, HighRiskCity city) {
    return Card(
      color: navyBlue.withOpacity(0.75), // Slightly more transparent
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TranslatableText(
              "${city.city}, ${city.state}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: _getMagnitudeColor(city.magnitude), size: 18),
                const SizedBox(width: 8),
                TranslatableText(
                  "Magnitude: ${city.magnitude.toString()}",
                  style: TextStyle(
                    color: _getMagnitudeColor(city.magnitude),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getMagnitudeColor(double magnitude) {
    if (magnitude >= 5.5) return Colors.redAccent;
    if (magnitude >= 4.5) return Colors.orangeAccent;
    return Colors.yellowAccent; // Low to moderate
  }

  Future<void> _launchReadMoreUrl() async {
    if (earthquakePrediction.readMoreUrl.isNotEmpty) {
      final Uri url = Uri.parse(earthquakePrediction.readMoreUrl);
      if (!await launchUrl(url)) {
        // Consider showing a SnackBar or message if launch fails
        print('Could not launch ${earthquakePrediction.readMoreUrl}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TranslatableText(
          "Earthquake Risk Details",
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
        child: Column( // Changed to Column to accommodate the "Read More" button outside ListView
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const TranslatableText(
                    "High-Risk Cities/Areas:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 2.0, color: Colors.black26, offset: Offset(1,1))]
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (earthquakePrediction.highRiskCities.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TranslatableText(
                          "No specific high-risk cities reported at this moment.",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...earthquakePrediction.highRiskCities.map((city) => _buildCityRiskCard(context, city)).toList(),
                ],
              ),
            ),
            if (earthquakePrediction.readMoreUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: const TranslatableText("Read More Insights"),
                  onPressed: _launchReadMoreUrl,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16)
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
