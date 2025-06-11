import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsc/app/central/modules/dashboard/active_disasters_map_page.dart';
import 'package:gsc/models/disaster_event.dart';
import 'package:gsc/models/flood_prediction.dart';
import 'package:gsc/models/cyclone_prediction.dart';
import 'package:gsc/models/earthquake_prediction.dart';
import 'package:gsc/services/disaster_service.dart';
import 'package:provider/provider.dart';

// Re-using manual mock from dashboard_page_test.dart (ideally this would be in a shared test_helper.dart)
class MockDisasterService implements DisasterService {
  List<DisasterEvent> mockDisasterEvents = [];
  bool shouldThrowError = false;

  @override
  Future<List<DisasterEvent>> fetchAndFilterDisasterData() async {
    if (shouldThrowError) {
      throw Exception('Mock Service Error');
    }
    return Future.value(mockDisasterEvents);
  }
}

// Mock for Firebase Database
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:gsc/main.dart' as app_main;


// Re-using LanguageProvider mock
class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  Locale get currentLocale => _currentLocale;
  void changeLanguage(Locale newLocale) { _currentLocale = newLocale; notifyListeners(); }
  String translate(String key) { return key; }
}


void main() {
  late MockDisasterService mockDisasterService;
  late FirebaseDatabase originalFirebaseDatabase;

  setUp(() {
    mockDisasterService = MockDisasterService();
    originalFirebaseDatabase = app_main.firebaseDatabase;
    app_main.firebaseDatabase = MockFirebaseDatabase.instance;
    MockFirebaseDatabase.instance.ref().child('raised_alerts').set({});
  });

  tearDown(() {
    app_main.firebaseDatabase = originalFirebaseDatabase;
    MockFirebaseDatabase.instance.ref().child('raised_alerts').set({});
  });

  Future<void> pumpActiveDisastersMapPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<DisasterService>.value(value: mockDisasterService),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ],
        child: MaterialApp(home: ActiveDisastersMapPage()),
      ),
    );
  }

  final mockFloodEvent = DisasterEvent(
    type: DisasterType.flood,
    predictionData: FloodPrediction(lat: 10, lon: 10, district: 'Test Flood District', state: 'Test State', country: 'India', risk: 'High'),
    timestamp: DateTime.now(),
  );
  final mockCycloneEvent = DisasterEvent(
    type: DisasterType.cyclone,
    predictionData: CyclonePrediction(lat: 12, lon: 12, district: 'Test Cyclone District', state: 'Test State', country: 'India', condition: 'Category 3'),
    timestamp: DateTime.now(),
  );

  testWidgets('ActiveDisastersMapPage displays loading indicator then disaster events in list and map', (WidgetTester tester) async {
    mockDisasterService.mockDisasterEvents = [mockFloodEvent, mockCycloneEvent];

    await pumpActiveDisastersMapPage(tester); // Initial pump
    expect(find.byType(CircularProgressIndicator), findsOneWidget); // Loading state

    await tester.pumpAndSettle(); // Finish loading

    // Check for map
    expect(find.byType(FlutterMap), findsOneWidget);
    // Check for list items (Cards are used for list items)
    expect(find.byType(Card), findsNWidgets(mockDisasterService.mockDisasterEvents.length));
    // Check for specific text from events
    expect(find.textContaining('Test Flood District'), findsOneWidget);
    expect(find.textContaining('Risk: High'), findsOneWidget);
    expect(find.textContaining('Test Cyclone District'), findsOneWidget);
    expect(find.textContaining('Condition: Category 3'), findsOneWidget);

    // Check for markers (a bit indirect, depends on _buildMarkers logic)
    // For each event that has a point, a Marker should be there. Both mock events have points.
    expect(find.byType(MarkerLayer), findsOneWidget);
    final MarkerLayer markerLayer = tester.widget(find.byType(MarkerLayer));
    expect(markerLayer.markers.length, mockDisasterService.mockDisasterEvents.length);
  });

  testWidgets('ActiveDisastersMapPage displays "no events" message', (WidgetTester tester) async {
    mockDisasterService.mockDisasterEvents = [];
    await pumpActiveDisastersMapPage(tester);
    await tester.pumpAndSettle();

    expect(find.text('No active disasters to display.'), findsOneWidget);
  });

  testWidgets('ActiveDisastersMapPage "Raise Alert" button sends data to Firebase', (WidgetTester tester) async {
    mockDisasterService.mockDisasterEvents = [mockCycloneEvent]; // Using cyclone for variety
    await pumpActiveDisastersMapPage(tester);
    await tester.pumpAndSettle();

    // Ensure the list item is present
    expect(find.textContaining('Test Cyclone District'), findsOneWidget);

    // Find the "Raise Alert" button associated with this event
    // The button is a direct child Text("Raise Alert") of an ElevatedButton
    final raiseAlertButtonFinder = find.widgetWithText(ElevatedButton, "Raise Alert");
    expect(raiseAlertButtonFinder, findsOneWidget);

    await tester.tap(raiseAlertButtonFinder);
    await tester.pumpAndSettle(); // For SnackBar and Firebase call

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Alert raised for cyclone at Test Cyclone District'), findsOneWidget);

    final dbSnapshot = await app_main.firebaseDatabase.ref('raised_alerts').once();
    final Map<dynamic, dynamic>? data = dbSnapshot.snapshot.value as Map<dynamic, dynamic>?;
    expect(data, isNotNull);
    expect(data!.values.length, 1);
    final alertEntry = data.values.first as Map<dynamic, dynamic>;
    expect(alertEntry['disasterType'], 'cyclone');
    expect(alertEntry['locationSummary'], 'Test Cyclone District');
    expect(alertEntry['riskSeverity'], contains('Category 3'));
    expect(alertEntry['latitude'], 12.0);
    expect(alertEntry['longitude'], 12.0);
  });

  testWidgets('ActiveDisastersMapPage shows error SnackBar if "Raise Alert" fails', (WidgetTester tester) async {
    mockDisasterService.mockDisasterEvents = [mockFloodEvent];
    await pumpActiveDisastersMapPage(tester);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ElevatedButton, "Raise Alert"), findsOneWidget);

    MockFirebaseDatabase.instance.ref('raised_alerts').setSimulateError(true);

    await tester.tap(find.widgetWithText(ElevatedButton, "Raise Alert"));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Error raising alert:'), findsOneWidget);

    MockFirebaseDatabase.instance.ref('raised_alerts').setSimulateError(false);
  });
}
