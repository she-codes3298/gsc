import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Import FirebaseAuth
import 'package:flutter_gemini/flutter_gemini.dart';
import 'firebase_options.dart';
import 'app/modules/login/login_page.dart';
import 'app/central/modules/dashboard/dashboard_page.dart';
import 'app/central/modules/community/community_page.dart';
import 'app/central/modules/inventory/inventory_page.dart';
import 'app/central/modules/settings/settings_page.dart';
import 'app/central/modules/ai_chatbot.dart'; // ✅ Import Chatbot Page
import 'app/central/modules/camps/camp_management_map.dart'; // ✅ Import Camp Management Page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Prevent multiple Firebase initializations
  await initializeFirebase();

  print("Firebase initialized successfully");

  // Ensure user is authenticated
  await ensureAuthenticated();

  Gemini.init(apiKey: "AIzaSyADGh1jYjjOA5hNJVVFUzBwNZ-SVMYdqXc");

  runApp(const MyApp());
}

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase already initialized: $e");
  }
}

Future<void> ensureAuthenticated() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    await auth.signInAnonymously(); // Sign in the government app anonymously
    print("Signed in anonymously as: ${auth.currentUser?.uid}");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/', // ✅ Set the initial page
      routes: {
        '/': (context) => const LoginPage(),
        '/gov_dashboard': (context) => const CentralDashboardPage(),
        '/gov_community': (context) => CommunityPage(),
        '/gov_inventory': (context) => InventoryPage(),
        '/gov_settings': (context) => SettingsPage(),
        '/ai_chatbot': (context) => AIChatbotScreen(), // ✅ E-Sahyog AI Chatbot
        '/camp': (context) => RefugeeCampPage(),
      },
    );
  }
}
