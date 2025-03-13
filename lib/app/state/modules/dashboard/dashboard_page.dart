import 'package:flutter/material.dart';

class StateDashboardPage extends StatelessWidget {
  const StateDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("State Government Dashboard"),
      ),
      body: const Center(
        child: Text("State Government Dashboard", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}