import 'package:flutter/material.dart';
<<<<<<< HEAD
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

=======
import 'app/modules/civilian_dashboard/views/civilian_dashboard_view.dart';
import 'app/modules/predictive_ai/views/predictive_ai_page.dart';
import 'app/modules/learn/views/learn_page.dart';
import 'app/modules/refugee_camp/views/refugee_camp_page.dart';
import 'app/modules/sos/views/sos_page.dart';
import 'app/modules/user_guide/views/user_guide_page.dart';
import 'app/modules/call/views/call_page.dart';
import 'app/modules/profile/views/profile_page.dart';
import 'app/modules/community_history/views/community_history_page.dart';

void main() {
>>>>>>> 59efa42 (Initial commit)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
<<<<<<< HEAD
  const MyApp({super.key});
=======
  const MyApp({Key? key}) : super(key: key);

  // Define the named routes here.
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const CivilianDashboardView(),
    '/predictive_ai': (context) => const PredictiveAIPage(),
    '/learn': (context) => const LearnPage(),
    '/refugee_camp': (context) => const RefugeeCampPage(),
    '/sos': (context) => const SOSPage(),
    '/user_guide': (context) => const UserGuidePage(),
    '/call': (context) => const CallPage(),
    '/profile': (context) => const ProfilePage(),
    '/community_history': (context) => const CommunityHistoryPage(),
  };
>>>>>>> 59efa42 (Initial commit)

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< HEAD
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
      },
=======
      title: 'Disaster Management App',
      debugShowCheckedModeBanner: false,
      routes: routes,
      initialRoute: '/',
>>>>>>> 59efa42 (Initial commit)
    );
  }
}
