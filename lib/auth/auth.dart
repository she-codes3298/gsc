import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../app/central/modules/dashboard/dashboard_page.dart';
import '../app/state/modules/dashboard/dashboard_page.dart';
import '../app/modules/login/login_page.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Sign in with Email & Password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
    required String role, // Added role parameter
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        if (role == "central_gov") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CentralDashboardPage(),
            ),
          );
        } else if (role == "state_gov") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StateDashboardPage()),
          );
        }
      }
    } catch (e) {
      print("Error in sign-in: $e");
      rethrow; // Rethrow the error to handle it in the UI
    }
  }

  // Register with Email & Password
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
    required String role, // Added role parameter
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        if (role == "central_gov") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CentralDashboardPage(),
            ),
          );
        } else if (role == "state_gov") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StateDashboardPage()),
          );
        }
      }
    } catch (e) {
      print("Error in sign-up: $e");
      rethrow; // Rethrow the error to handle it in the UI
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _firebaseAuth.signOut();
      print("User signed out successfully"); // Debug print

      // Navigate to LoginPage after signing out
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      print("Error signing out: $e"); // Debug print
    }
  }
}
