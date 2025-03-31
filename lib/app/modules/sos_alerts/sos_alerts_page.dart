import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SOSAlertsPage extends StatefulWidget {
  const SOSAlertsPage({super.key});

  @override
  _SOSAlertsPageState createState() => _SOSAlertsPageState();
}

class _SOSAlertsPageState extends State<SOSAlertsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🚨 SOS Alerts"), backgroundColor: Colors.red),
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('SOS_ALERTS').snapshots(), // ✅ Fetching SOS Alerts
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("❌ Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("✅ No active SOS alerts", style: TextStyle(color: Colors.white)),
            );
          }

          List<DocumentSnapshot> sosAlerts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: sosAlerts.length,
            itemBuilder: (context, index) {
              var alertData = sosAlerts[index].data();
              if (alertData == null || alertData is! Map<String, dynamic>) {
                return const SizedBox.shrink();
              }

              return Card(
                color: Colors.red[400],
                child: ListTile(
                  leading: const Icon(Icons.sos, color: Colors.white),
                  title: Text("🆘 ${alertData['name']}", style: const TextStyle(color: Colors.white)),
                  subtitle: Text("📍 ${alertData['location']}\n📞 ${alertData['phone']}", style: const TextStyle(color: Colors.white70)),
                  trailing: ElevatedButton(
                    onPressed: () => _assignRescueTeam(sosAlerts[index].id),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Assign Team", style: TextStyle(color: Colors.white)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ✅ Function to auto-assign rescue team when button is clicked
  void _assignRescueTeam(String alertId) async {
    await _firestore.collection('SOS_ALERTS').doc(alertId).update({
      'status': 'Assigned to Rescue Team',
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🚑 Rescue Team Assigned!")));
  }
}
