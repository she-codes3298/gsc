import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

class TeamDetailsPage extends StatefulWidget {
  final String teamId;
  final String teamName;
  final String? teamLocation;
  final List<dynamic> members;

  const TeamDetailsPage({
    Key? key,
    required this.teamId,
    required this.teamName,
    this.teamLocation,
    this.members = const [],
  }) : super(key: key);

  @override
  _TeamDetailsPageState createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController nameController = TextEditingController();
  String statusValue = "Active";

  void _addNewMember(String name, String status) {
    final Random random = Random();
    double latitude = 28.0 + random.nextDouble() * 0.1;
    double longitude = 77.0 + random.nextDouble() * 0.1;
    int bpm = 60 + random.nextInt(40);

    _database.child('teams/${widget.teamId}/members').push().set({
      'name': name,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'ECG': bpm,
    });
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Team Member"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              SizedBox(height: 10),
              StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButtonFormField<String>(
                    value: statusValue,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => statusValue = value);
                      }
                    },
                    items:
                        ["Active", "Standby", "Inactive"]
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a valid name")),
                  );
                } else {
                  _addNewMember(nameController.text.trim(), statusValue);
                  Navigator.pop(context);
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teamName),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _showAddMemberDialog),
        ],
      ),
      body: // StreamBuilder inside build method
          StreamBuilder(
        stream: _database.child('teams/${widget.teamId}/members').onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return Center(child: Text("No team members found"));
          }

          var rawData = snapshot.data!.snapshot.value;
          Map<dynamic, dynamic> members = {};

          // Convert List to Map if needed
          if (rawData is List) {
            for (int i = 0; i < rawData.length; i++) {
              if (rawData[i] != null) {
                members[i.toString()] = rawData[i];
              }
            }
          } else if (rawData is Map<dynamic, dynamic>) {
            members = rawData;
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    String key = members.keys.elementAt(index).toString();
                    Map<dynamic, dynamic> member = members[key];

                    String name = (member["name"] ?? "Unknown").toString();
                    String status = (member["status"] ?? "Unknown").toString();
                    double lat = (member["latitude"] ?? 0.0).toDouble();
                    double long = (member["longitude"] ?? 0.0).toDouble();
                    String ecg = (member["ECG"] ?? "Unknown BPM").toString();

                    Color statusColor =
                        status == "Active"
                            ? Colors.green
                            : status == "Standby"
                            ? Colors.orange
                            : Colors.grey;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: statusColor,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(name),
                      subtitle: Text("ECG: $ecg BPM"),
                      trailing: Text(
                        status,
                        style: TextStyle(color: statusColor),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
