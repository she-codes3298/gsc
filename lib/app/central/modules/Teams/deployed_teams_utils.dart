// lib/app/central/modules/Teams/deployed_teams_utils.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class DeployedTeamsUtils {
  static Future<void> createDummyTeams() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    List<Map<String, dynamic>> teams = [
      {
        "name": "Rescue Squad Alpha",
        "location": "Downtown Sector 5",
        "members": [
          {
            "name": "John Doe",
            "ECG": "72 BPM",
            "location": {"lat": 28.7041, "long": 77.1025},
            "status": "Active",
          },
          {
            "name": "Jane Smith",
            "ECG": "75 BPM",
            "location": {"lat": 28.7050, "long": 77.1030},
            "status": "Active",
          },
        ],
      },
      {
        "name": "Rapid Response Beta",
        "location": "Uptown Zone 3",
        "members": [
          {
            "name": "Alice Brown",
            "ECG": "70 BPM",
            "location": {"lat": 28.7001, "long": 77.1005},
            "status": "Standby",
          },
          {
            "name": "Bob Johnson",
            "ECG": "68 BPM",
            "location": {"lat": 28.7015, "long": 77.1012},
            "status": "Active",
          },
        ],
      },
      {
        "name": "Emergency Task Force Gamma",
        "location": "Central District 2",
        "members": [
          {
            "name": "Charlie Wilson",
            "ECG": "74 BPM",
            "location": {"lat": 28.7100, "long": 77.1100},
            "status": "Active",
          },
          {
            "name": "David Lee",
            "ECG": "69 BPM",
            "location": {"lat": 28.7112, "long": 77.1125},
            "status": "Inactive",
          },
        ],
      },
    ];

    // Check if teams already exist
    QuerySnapshot existingTeams =
        await firestore.collection('deployed_teams').get();
    if (existingTeams.docs.isNotEmpty) {
      print("Teams already exist in the database.");
      return;
    }

    for (var team in teams) {
      DocumentReference teamRef = await firestore
          .collection('deployed_teams')
          .add({"name": team["name"], "location": team["location"]});

      for (var member in team["members"]) {
        await teamRef.collection("members").add(member);
      }
    }

    print("✅ Dummy teams added successfully!");
  }
}
