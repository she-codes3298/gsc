// lib/models/cyclone_prediction.dart
class CyclonePrediction {
  final String timestampUtc;
  final Location location;
  final WeatherData weatherData;
  final String cycloneCondition;

  CyclonePrediction({
    required this.timestampUtc,
    required this.location,
    required this.weatherData,
    required this.cycloneCondition,
  });

  factory CyclonePrediction.fromJson(Map<String, dynamic> json) {
    return CyclonePrediction(
      timestampUtc: json['timestamp_utc'] ?? 'N/A',
      location: Location.fromJson(json['location'] ?? {}),
      weatherData: WeatherData.fromJson(json['weather_data'] ?? {}),
      cycloneCondition: json['cyclone_condition'] ?? 'Unknown',
    );
  }
}

class Location {
  final double latitude;
  final double longitude;
  final String district;

  Location({
    required this.latitude,
    required this.longitude,
    required this.district,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      district: json['district'] ?? 'Unknown',
    );
  }
}

class WeatherData {
  final double usaWind; // Assuming double, adjust if necessary
  final int usaPres;   // Assuming int, adjust if necessary
  final int stormSpeed; // Assuming int, adjust if necessary
  final int stormDir;
  final int month;

  WeatherData({
    required this.usaWind,
    required this.usaPres,
    required this.stormSpeed,
    required this.stormDir,
    required this.month,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      usaWind: (json['usa_wind'] as num?)?.toDouble() ?? 0.0,
      usaPres: (json['usa_pres'] as num?)?.toInt() ?? 0,
      stormSpeed: (json['storm_speed'] as num?)?.toInt() ?? 0,
      stormDir: (json['storm_dir'] as num?)?.toInt() ?? 0,
      month: (json['month'] as num?)?.toInt() ?? 0,
    );
  }
}
