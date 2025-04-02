import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';


import 'app/central/modules/Teams/teams_page.dart';

import 'firebase_options.dart';
import 'app/modules/login/login_page.dart';
import 'app/central/modules/dashboard/dashboard_page.dart';
import 'app/central/modules/community/community_page.dart';
import 'app/central/modules/inventory/inventory_page.dart';
import 'app/central/modules/settings/settings_page.dart';
import 'app/central/modules/ai_chatbot.dart';
import 'app/central/modules/camps/camp_management_map.dart';
import 'app/modules/sos_alerts/sos_alerts_page.dart';

import 'providers/language_provider.dart';

import 'package:firebase_database/firebase_database.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 🔔 Global instance for local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =

FlutterLocalNotificationsPlugin();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  await ensureAuthenticated();

  // ✅ Initialize Gemini AI (Only once)

  Gemini.init(apiKey: "AIzaSyADGh1jYjjOA5hNJVVFUzBwNZ-SVMYdqXc");


  runApp(const MyApp());

  // ✅ Setup Firebase Messaging AFTER `runApp`
  setupFirebaseMessaging();
}

// Global variable to store the correct database instance
late FirebaseDatabase firebaseDatabase;

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );


    // Assign the correct database instance to the global variable
    firebaseDatabase = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: "https://ecgtest.firebaseio.com/",
    );


    print("✅ Firebase initialized successfully");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }
}

Future<void> ensureAuthenticated() async {
  try {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
      print("✅ Signed in anonymously as: ${auth.currentUser?.uid}");
    }
  } catch (e) {
    print("❌ Firebase Authentication failed: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        navigatorKey: navigatorKey,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/sos_alerts': (context) => SOSAlertsPage(),
          '/gov_dashboard': (context) => const CentralDashboardPage(),
          '/gov_community': (context) => CommunityPage(),
          '/gov_inventory': (context) => InventoryPage(),
          '/gov_settings': (context) => SettingsPage(),
          '/ai_chatbot': (context) => AIChatbotScreen(),
          '/camp': (context) => RefugeeCampPage(),
        },
      ),

    );
  }
}

/// 🔹 **Setup Firebase Messaging**
void setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request Notification Permissions
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

  // Subscribe to "sos_alerts" topic
  await messaging.subscribeToTopic("sos_alerts");
  print("📡 Subscribed to SOS Alerts!");

  // ✅ Initialize local notifications BEFORE showing notifications
  setupLocalNotifications();

  // 🔥 Handle messages when the app is in the foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📩 Foreground Notification: ${message.notification?.title}");
    if (message.notification != null) {
      _showLocalNotification(message.notification!);
    }
  });

  // 🔥 Handle message clicks (background & terminated)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("🚀 Notification Clicked! Navigating to SOS Alerts Page.");
    navigatorKey.currentState?.pushNamed('/sos_alerts');
  });

  // 🔥 Background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔥 Store FCM Token in Firestore & handle refresh
  storeFCMToken();
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    storeFCMToken(newToken);
  });
}

/// 🔔 **Setup Local Notifications**
void setupLocalNotifications() {
  const AndroidInitializationSettings androidInitSettings =

  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
  );

  flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print("🚀 Notification Clicked (Local)");
      navigatorKey.currentState?.pushNamed('/sos_alerts');
    },
  );
}

/// 📢 **Show Local Notification**
void _showLocalNotification(RemoteNotification notification) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =

      AndroidNotificationDetails(
        'sos_channel',
        'SOS Alerts',
        channelDescription: 'Emergency SOS notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );


  await flutterLocalNotificationsPlugin.show(
    0,
    notification.title,
    notification.body,
    platformChannelSpecifics,
  );
}

/// 📩 **Handle Background Messages**
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📢 Background Notification: ${message.notification?.title}");
}

/// 📡 **Store FCM Token in Firestore**
void storeFCMToken([String? newToken]) async {
  try {
    String? token = newToken ?? await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('FCM_TOKENS')
          .doc('gsc_app')
          .set({'token': token, 'timestamp': FieldValue.serverTimestamp()});
      print("✅ FCM Token Stored: $token");
    }
  } catch (e) {
    print("❌ Error storing FCM Token: $e");
  }

}

