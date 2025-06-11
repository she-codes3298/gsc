import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsc/models/disaster_event.dart';
import 'package:gsc/models/cyclone_prediction.dart';
import 'package:gsc/models/earthquake_prediction.dart';
import 'package:gsc/models/flood_prediction.dart';
import 'package:gsc/services/disaster_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// Helper function to create mock responses
MockClient getMockClient(String floodResponse, String cycloneResponse, String earthquakeResponse, {
  int floodStatusCode = 200,
  int cycloneStatusCode = 200,
  int earthquakeStatusCode = 200,
}) {
  return MockClient((request) async {
    if (request.url.toString().contains('flood-api')) {
      return http.Response(floodResponse, floodStatusCode);
    } else if (request.url.toString().contains('cyclone-api')) {
      return http.Response(cycloneResponse, cycloneStatusCode);
    } else if (request.url.toString().contains('my-python-app')) { // Earthquake API
      return http.Response(earthquakeResponse, earthquakeStatusCode);
    }
    // Fallback for any other unexpected request
    return http.Response('Not Found: ${request.url}', 404);
  });
}

void main() {
  group('DisasterService Tests', () {
    // Default empty responses for APIs not under specific test
    final defaultEmptyFloodResponse = jsonEncode([]); // Assuming API returns list for no data
    final defaultEmptyCycloneResponse = jsonEncode([]); // Assuming API returns list for no data
    // For earthquake, an empty list of cities is more appropriate for "no event"
    final defaultEmptyEarthquakeResponse = jsonEncode({'high_risk_cities': [], 'read_more_url': ''});

    test('fetchAndFilterDisasterData returns empty list when all APIs error out', () async {
      final mockClient = getMockClient(
        'Error', 'Error', 'Error',
        floodStatusCode: 500, cycloneStatusCode: 500, earthquakeStatusCode: 500,
      );
      final service = DisasterService(client: mockClient);
      final results = await service.fetchAndFilterDisasterData();
      expect(results, isEmpty);
    });

    test('fetchAndFilterDisasterData correctly filters flood events by risk and location', () async {
      final mockFloodData = [
        // Valid: Medium risk, India
        {"lat": 28.7041, "lon": 77.1025, "district": "Delhi", "state": "Delhi", "country": "India", "risk": "Medium"},
        // Valid: High risk, India
        {"lat": 19.0760, "lon": 72.8777, "district": "Mumbai", "state": "Maharashtra", "country": "India", "risk": "High"},
        // Invalid: Low risk, India
        {"lat": 22.5726, "lon": 88.3639, "district": "Kolkata", "state": "West Bengal", "country": "India", "risk": "Low"},
        // Invalid: No flood, India
        {"lat": 13.0827, "lon": 80.2707, "district": "Chennai", "state": "Tamil Nadu", "country": "India", "risk": "No Flood"},
        // Invalid: Medium risk, Not India
        {"lat": 24.8607, "lon": 67.0011, "district": "Karachi", "state": "Sindh", "country": "Pakistan", "risk": "Medium"},
      ];

      // Mock client setup:
      // We need to simulate multiple POST requests for floods, one for each representativeLocation in India.
      // The DisasterService._representativeLocations has 12 Indian locations.
      // The current MockClient setup is too simple for this. It returns the same response for any flood-api call.
      // This test will need a more sophisticated MockClient that can differentiate calls or expect multiple calls.
      // For now, this test will likely fail or not test thoroughly due to this limitation.
      // A quick fix for the test is to assume only one Indian location is processed, or simplify the mock.

      // Simplified approach for this test: Assume DisasterService only processes the first matching Indian location.
      // This is NOT how the actual service works, but it's a constraint of simple MockClient.
      final client = MockClient((request) async {
        if (request.url.toString().contains('flood-api')) {
          // For simplicity, we'll just use the first flood data item for all Indian locations.
          // This means the test will assert based on this single item being processed multiple times (incorrectly)
          // or we filter _representativeLocations in the test setup to have only one Indian city.
          // Let's assume the service is called for Delhi (first in _representativeLocations)
           final reqBody = jsonDecode(request.body);
           if (reqBody['lat'] == 28.7041 && reqBody['lon'] == 77.1025) { // Delhi
             return http.Response(jsonEncode(mockFloodData[0]), 200); // Medium risk
           } else if (reqBody['lat'] == 19.0760 && reqBody['lon'] == 72.8777) { // Mumbai
             return http.Response(jsonEncode(mockFloodData[1]), 200); // High risk
           } else if (reqBody['lat'] == 22.5726 && reqBody['lon'] == 88.3639) { // Kolkata
             return http.Response(jsonEncode(mockFloodData[2]), 200); // Low risk
           } else if (reqBody['lat'] == 13.0827 && reqBody['lon'] == 80.2707) { // Chennai
             return http.Response(jsonEncode(mockFloodData[3]), 200); // No flood
           }
          // For other Indian cities, return "No Flood" to keep test focused.
          return http.Response(jsonEncode({"lat": 0.0, "lon": 0.0, "district": "Test", "state": "Test", "country": "India", "risk": "No Flood"}), 200);
        }
        if (request.url.toString().contains('cyclone-api')) {
            return http.Response(defaultEmptyCycloneResponse, 200);
        }
        if (request.url.toString().contains('my-python-app')) {
            return http.Response(defaultEmptyEarthquakeResponse, 200);
        }
        return http.Response('Not Found', 404);
      });

      final service = DisasterService(client: client);
      final results = await service.fetchAndFilterDisasterData();

      final floodEvents = results.where((e) => e.type == DisasterType.flood).toList();
      // Expect 2 flood events: Delhi (Medium) and Mumbai (High)
      expect(floodEvents.length, 2);
      expect(floodEvents.every((e) {
        final data = e.predictionData as FloodPrediction;
        return (data.floodRisk.toLowerCase() == 'medium' || data.floodRisk.toLowerCase() == 'high');
      }), isTrue);
       expect(floodEvents.every((e) => (e.predictionData as FloodPrediction).country.toLowerCase() == 'india'), isTrue, reason: "All flood events should be in India");

    });

    test('fetchAndFilterDisasterData correctly filters cyclone events by category and location', () async {
       final mockCycloneDataList = [
        // Valid: Category 2, India
        {"lat": 28.7041, "lon": 77.1025, "district": "Delhi", "state": "Delhi", "country": "India", "condition": "Category 2"},
        // Valid: Category 3, India
        {"lat": 19.0760, "lon": 72.8777, "district": "Mumbai", "state": "Maharashtra", "country": "India", "condition": "Category 3"},
        // Invalid: Category 1, India
        {"lat": 22.5726, "lon": 88.3639, "district": "Kolkata", "state": "West Bengal", "country": "India", "condition": "Category 1"},
        // Invalid: Tropical Storm, India
        {"lat": 13.0827, "lon": 80.2707, "district": "Chennai", "state": "Tamil Nadu", "country": "India", "condition": "Tropical Storm"},
        // Invalid: Category 2, Not India
        {"lat": 24.8607, "lon": 67.0011, "district": "Karachi", "state": "Sindh", "country": "Pakistan", "condition": "Category 2"},
      ];

      final client = MockClient((request) async {
        if (request.url.toString().contains('cyclone-api')) {
           final reqBody = jsonDecode(request.body);
           if (reqBody['lat'] == 28.7041 && reqBody['lon'] == 77.1025) { // Delhi
             return http.Response(jsonEncode(mockCycloneDataList[0]), 200); // Cat 2
           } else if (reqBody['lat'] == 19.0760 && reqBody['lon'] == 72.8777) { // Mumbai
             return http.Response(jsonEncode(mockCycloneDataList[1]), 200); // Cat 3
           } else if (reqBody['lat'] == 22.5726 && reqBody['lon'] == 88.3639) { // Kolkata
             return http.Response(jsonEncode(mockCycloneDataList[2]), 200); // Cat 1
           } else if (reqBody['lat'] == 13.0827 && reqBody['lon'] == 80.2707) { // Chennai
             return http.Response(jsonEncode(mockCycloneDataList[3]), 200); // Tropical Storm
           }
          // For other Indian cities, return "No Cyclone"
          return http.Response(jsonEncode({"lat": 0.0, "lon": 0.0, "district": "Test", "state": "Test", "country": "India", "condition": "No Cyclone"}), 200);
        }
         if (request.url.toString().contains('flood-api')) {
            return http.Response(defaultEmptyFloodResponse, 200);
        }
        if (request.url.toString().contains('my-python-app')) {
            return http.Response(defaultEmptyEarthquakeResponse, 200);
        }
        return http.Response('Not Found', 404);
      });

      final service = DisasterService(client: client);
      final results = await service.fetchAndFilterDisasterData();
      final cycloneEvents = results.where((e) => e.type == DisasterType.cyclone).toList();

      expect(cycloneEvents.length, 2); // Delhi (Cat 2) and Mumbai (Cat 3)
      expect(cycloneEvents.every((e) {
        final data = e.predictionData as CyclonePrediction;
        final condition = data.cycloneCondition.toLowerCase();
        if (condition.startsWith("category")) {
          final categoryNumber = int.tryParse(condition.split(" ")[1]);
          return categoryNumber != null && categoryNumber >= 2;
        }
        return false;
      }), isTrue);
      expect(cycloneEvents.every((e) => (e.predictionData as CyclonePrediction).country.toLowerCase() == 'india'), isTrue, reason: "All cyclone events should be in India");
    });

    test('fetchAndFilterDisasterData correctly filters earthquake events by magnitude and location', () async {
      final mockEarthquakeData = {
        "high_risk_cities": [
          // Valid: Magnitude >= 3.2, India
          {"city": "Delhi", "state": "India", "magnitude": 4.5},
          // Valid: Magnitude == 3.2, India
          {"city": "Mumbai", "state": "India", "magnitude": 3.2},
          // Invalid: Magnitude < 3.2, India
          {"city": "Kolkata", "state": "India", "magnitude": 2.8},
          // Invalid: Magnitude >= 3.2, Not India
          {"city": "Lahore", "state": "Pakistan", "magnitude": 5.0},
           // Valid: Another city in India, low magnitude, but overall event should be included due to Delhi/Mumbai
          {"city": "Jaipur", "state": "India", "magnitude": 3.0},
        ],
        "read_more_url": "http://example.com/earthquake"
      };

      final client = getMockClient(
        defaultEmptyFloodResponse,
        defaultEmptyCycloneResponse,
        jsonEncode(mockEarthquakeData)
      );
      final service = DisasterService(client: client);
      final results = await service.fetchAndFilterDisasterData();
      final earthquakeEvents = results.where((e) => e.type == DisasterType.earthquake).toList();

      expect(earthquakeEvents.length, 1); // Only one earthquake event is fetched
      final eventData = earthquakeEvents.first.predictionData as EarthquakePrediction;
      // The event is included if ANY city meets magnitude AND ANY city is in India.
      // The filtering logic in DisasterService is:
      // meetsMagnitudeCriteria = true if ANY city.magnitude >= 3.2
      // isLocatedInIndia = true if ANY city.state.toLowerCase() == 'india'
      // Event added if meetsMagnitudeCriteria AND isLocatedInIndia.

      // Expected: Delhi (4.5, India) and Mumbai (3.2, India) make the event valid.
      // Lahore (5.0, Pakistan) meets magnitude but not location for the *event's* India criteria.
      // Kolkata (2.8, India) meets location but not magnitude.
      // Jaipur (3.0, India) meets location but not magnitude.

      // The event itself should be included because Delhi and Mumbai make it meet both criteria.
      // The returned event will contain ALL highRiskCities from the API.
      expect(eventData.highRiskCities.length, 5);
    });

    test('fetchAndFilterDisasterData returns empty list if only non-India locations for floods/cyclones and non-India earthquakes', () async {
      final mockNonIndiaFlood = jsonEncode({"lat": 1.0, "lon": 1.0, "district": "Test", "state": "Test", "country": "Pakistan", "risk": "High"});
      final mockNonIndiaCyclone = jsonEncode({"lat": 1.0, "lon": 1.0, "district": "Test", "state": "Test", "country": "Pakistan", "condition": "Category 3"});
      final mockNonIndiaEarthquake = jsonEncode({
        "high_risk_cities": [{"city": "Lahore", "state": "Pakistan", "magnitude": 4.0}],
        "read_more_url": ""
      });

      // This needs a MockClient that consistently returns non-India data for all Indian representative locations.
      final client = MockClient((request) async {
        if (request.url.toString().contains('flood-api')) {
          return http.Response(mockNonIndiaFlood, 200);
        } else if (request.url.toString().contains('cyclone-api')) {
           return http.Response(mockNonIndiaCyclone, 200);
        } else if (request.url.toString().contains('my-python-app')) {
           return http.Response(mockNonIndiaEarthquake, 200);
        }
        return http.Response('Not Found', 404);
      });

      final service = DisasterService(client: client);
      final results = await service.fetchAndFilterDisasterData();
      expect(results, isEmpty, reason: "Should be empty as all events are non-India based");
    });
  });
}

// Placeholder for DisasterType enum if not directly importable or to avoid full model import
// enum DisasterType { flood, cyclone, earthquake }
// (Actual models are imported, so this is not needed)
