import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/auth.dart';
import '../login/login_page.dart'; // Redirect back to login if user already has an account

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  String errorMessage = "";
  bool isLoading = false;
  String selectedRole = "central_gov"; // Default role

  void register() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      setState(() {
        errorMessage = "Please fill in all fields!";
      });
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = "Passwords do not match!";
      });
      return;
    }

    if (passwordController.text.length < 8) {
      setState(() {
        errorMessage = "Password must be at least 8 characters long!";
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _authService.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
        context: context,
        role: selectedRole, // Pass selected role to AuthService
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "An error occurred. Please try again.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            transform: GradientRotation(-40 * 3.14159 / 180), // -40 degrees in radians
            colors: [
              Color(0xFF87CEEB), // Sky Blue - lighter and more vibrant
              Color(0xFF4682B4), // Steel Blue - professional yet lighter
            ],
            stops: [0.3, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A324C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_add,
                          size: 48,
                          color: Color(0xFF1A324C),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "CREATE ACCOUNT",
                        style: TextStyle(
                          color: Color(0xFF1A324C),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField(emailController, "Email"),
                      const SizedBox(height: 20),
                      _buildTextField(passwordController, "Password", isPassword: true),
                      const SizedBox(height: 20),
                      _buildTextField(confirmPasswordController, "Confirm Password", isPassword: true),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF3789BB)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: selectedRole,
                          isExpanded: true,
                          underline: const SizedBox(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedRole = newValue!;
                            });
                          },
                          items: <String>['central_gov', 'state_gov']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value == 'central_gov' ? 'Central Government' : 'State Government',
                                style: const TextStyle(color: Color(0xFF1A324C)),
                              ),
                            );
                          }).toList(),
                          dropdownColor: Colors.white,
                          iconEnabledColor: const Color(0xFF3789BB),
                        ),
                      ),
                      const SizedBox(height: 30),
                      isLoading
                          ? const CircularProgressIndicator(
                        color: Color(0xFF3789BB),
                      )
                          : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3789BB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            "SIGN UP",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        ),
                        child: const Text(
                          "Already have an account? Login",
                          style: TextStyle(color: Color(0xFF3789BB)),
                        ),
                      ),
                      if (errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Color(0xFF1A324C)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF3789BB)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF3789BB)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF1A324C), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}