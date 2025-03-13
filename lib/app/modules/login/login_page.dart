import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/auth.dart';
import '../register/register_page.dart'; // Redirect to Register Page

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String errorMessage = "";
  bool isLoading = false;
  String selectedRole = "central_gov"; // Default role

  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        errorMessage = "Please fill in all fields!";
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _authService.signInWithEmailAndPassword(
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
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "GOVERNMENT LOGIN",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildTextField(emailController, "Email"),
              const SizedBox(height: 15),
              _buildTextField(passwordController, "Password", isPassword: true),
              const SizedBox(height: 15),
              DropdownButton<String>(
                value: selectedRole,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRole = newValue!;
                  });
                },
                items: <String>['central_gov', 'state_gov']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                dropdownColor: Colors.grey[900],
                iconEnabledColor: Colors.white,
              ),
              const SizedBox(height: 25),
              isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      child: const Text("LOGIN", style: TextStyle(color: Colors.black)),
                    ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                ),
                child: const Text("Don't have an account? Register", style: TextStyle(color: Colors.blue)),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // TODO: Implement password reset functionality
                },
                child: const Text("Forgot Password?", style: TextStyle(color: Colors.blue)),
              ),
              const SizedBox(height: 10),
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue)),
      ),
    );
  }
}