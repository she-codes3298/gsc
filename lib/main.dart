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
import 'app/central/modules/camps/camp_management_map.dart'; // ✅ Import Camp Management Page
import 'package:gsc/app/modules/sos_alerts/sos_alerts_page.dart'; // ✅ Import SOS Alerts Page
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }

  // Initialize FCM & Local Notifications
  setupFirebaseMessaging();

  // Initialize Gemini AI
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
      navigatorKey: navigatorKey,
      initialRoute: '/', // ✅ Set the initial page
      routes: {
        '/': (context) => const LoginPage(),
        '/sos_alerts': (context) => SOSAlertsPage(),
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

/// 🔹 **Setup Firebase Messaging**
void setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request Notification Permissions (Android 13+)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print("✅ Notifications Allowed");
  } else {
    print("❌ Notifications Denied");
  }

  // Subscribe to "sos_alerts" topic to receive SOS notifications
  await messaging.subscribeToTopic("sos_alerts");
  print("📡 Subscribed to SOS Alerts!");

  // Initialize local notifications
  setupLocalNotifications();

  // 🔥 Handle messages when app is in foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📩 Foreground Notification: ${message.notification?.title}");
    _showLocalNotification(message.notification!);
  });

  // 🔥 Handle message clicks (when app is in background or terminated)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("🚀 Notification Clicked! Navigating to SOS Alerts Page.");
    navigatorKey.currentState?.pushNamed('/sos_alerts');
  });
}

/// 🔔 **Setup Local Notifications**
void setupLocalNotifications() {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
  );

  flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload != null) {
        print("🚀 Notification Clicked (Local)");
        navigatorKey.currentState?.pushNamed('/sos_alerts');
      }
    },
  );
}

/// 📢 **Show Local Notification**
void _showLocalNotification(RemoteNotification notification) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'sos_channel',
    'SOS Alerts',
    channelDescription: 'Emergency SOS notifications',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    notification.title,
    notification.body,
    platformChannelSpecifics,
  );
}

/// 📩 **Handle Background Messages**
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📢 Background Notification: ${message.notification?.title}");
}
