import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'firebase_options.dart';
import 'app/modules/login/login_page.dart';
import 'app/central/modules/dashboard/dashboard_page.dart';
import 'app/central/modules/community/community_page.dart';
import 'app/central/modules/inventory/inventory_page.dart';
import 'app/central/modules/settings/settings_page.dart';
import 'app/central/modules/ai_chatbot.dart'; // ✅ Import Chatbot Page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  Gemini.init(apiKey: "AIzaSyADGh1jYjjOA5hNJVVFUzBwNZ-SVMYdqXc");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/gov_dashboard', // ✅ Set the initial page
      routes: {
        '/': (context) => const LoginPage(),
        '/gov_dashboard': (context) => const CentralDashboardPage(),
        '/gov_community': (context) => CommunityPage(),
        '/gov_inventory': (context) => InventoryPage(),
        '/gov_settings': (context) => SettingsPage(),
        '/ai_chatbot': (context) => AIChatbotScreen(), // ✅ E-Sahyog AI Chatbot
      },
    );
  }
}
