// lib/models/disaster_event.dart
import 'flood_prediction.dart';
import 'cyclone_prediction.dart';
import 'earthquake_prediction.dart';

enum DisasterType { flood, cyclone, earthquake, unknown }

class DisasterEvent {
  final DisasterType type;
  final dynamic
  predictionData; // This will hold FloodPrediction, CyclonePrediction, or EarthquakePrediction
  final DateTime
  timestamp; // Common field for when the event was fetched or occurred

  DisasterEvent({
    required this.type,
    required this.predictionData,
    required this.timestamp,
  });

  // Helper to get a general location string, if possible
  String get locationSummary {
    if (type == DisasterType.flood && predictionData is FloodPrediction) {
      return (predictionData as FloodPrediction).matchedDistrict;
    } else if (type == DisasterType.cyclone &&
        predictionData is CyclonePrediction) {
      return (predictionData as CyclonePrediction).location.district;
    } else if (type == DisasterType.earthquake &&
        predictionData is EarthquakePrediction) {
      if ((predictionData as EarthquakePrediction).highRiskCities.isNotEmpty) {
        return (predictionData as EarthquakePrediction)
            .highRiskCities
            .first
            .city;
      }
      return "Multiple Areas";
    }
    return "N/A";
  }

  // Helper to get a general severity string
  String get severitySummary {
    if (type == DisasterType.flood && predictionData is FloodPrediction) {
      return "Risk: ${(predictionData as FloodPrediction).floodRisk}";
    } else if (type == DisasterType.cyclone &&
        predictionData is CyclonePrediction) {
      return (predictionData as CyclonePrediction).cycloneCondition;
    } else if (type == DisasterType.earthquake &&
        predictionData is EarthquakePrediction) {
      if ((predictionData as EarthquakePrediction).highRiskCities.isNotEmpty) {
        // Find max magnitude or summarize
        double maxMag = 0;
        (predictionData as EarthquakePrediction).highRiskCities.forEach((city) {
          if (city.magnitude > maxMag) maxMag = city.magnitude;
        });
        return "Max Mag: $maxMag";
      }
      return "High Risk";
    }
    return "N/A";
  }
}
