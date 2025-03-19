import 'package:d_m/app/modules/splash_screen.dart';
import 'package:flutter/material.dart';
import 'app/modules/civilian_dashboard/views/civilian_dashboard_view.dart';
import 'app/modules/predictive_ai/views/predictive_ai_page.dart';
import 'app/modules/learn/views/learn_page.dart';
import 'app/modules/refugee_camp/views/refugee_camp_page.dart';
import 'app/modules/sos/views/sos_page.dart';
import 'app/modules/user_guide/views/user_guide_page.dart';
import 'app/modules/call/views/call_page.dart';
import 'app/modules/profile/views/profile_page.dart';
import 'app/modules/community_history/views/community_page.dart';
import 'app/modules/ai_chatbot.dart';
import 'package:flutter_gemini/flutter_gemini.dart'; // Import Gemini

void main() {
  Gemini.init(apiKey: 'AIzaSyADGh1jYjjOA5hNJVVFUzBwNZ-SVMYdqXc');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disaster Management App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Set splash screen as the initial route
      onGenerateRoute: (settings) {
        if (settings.name == '/community_history') {
          return MaterialPageRoute(
            builder: (context) => const CommunityPage(),
          );
        }

        return MaterialPageRoute(
          builder: (context) => routes[settings.name]!(context),
        );
      },

    );
  }

  // Define static named routes (only for routes without parameters)
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/civilian_dashboard': (context) => const CivilianDashboardView(),
    '/predictive_ai': (context) => const PredictiveAIPage(),
    '/learn': (context) => const LearnPage(),
    '/refugee_camp': (context) => const RefugeeCampPage(),
    '/sos': (context) => const SOSPage(),
    '/user_guide': (context) => const UserGuidePage(),
    '/call': (context) => CallPage(),
    '/profile': (context) => ProfilePage(),
    '/ai_chatbot': (context) => AIChatbotScreen(),
  };
}

