// lib/models/flood_prediction.dart
class FloodPrediction {
  final double lat;
  final double lon;
  final String originalDistrict;
  final String matchedDistrict;
  final String floodRisk;

  FloodPrediction({
    required this.lat,
    required this.lon,
    required this.originalDistrict,
    required this.matchedDistrict,
    required this.floodRisk,
  });

  factory FloodPrediction.fromJson(Map<String, dynamic> json) {
    return FloodPrediction(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      originalDistrict: json['original_district'] ?? 'Unknown',
      matchedDistrict: json['matched_district'] ?? 'Unknown',
      floodRisk: json['flood_risk'] ?? 'Unknown',
    );
  }
}
