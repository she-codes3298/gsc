import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TeamDetailsPage extends StatelessWidget {
  final String teamId;
  final String teamName;

  const TeamDetailsPage({
    Key? key,
    required this.teamId,
    required this.teamName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(teamName)),
      body: StreamBuilder<DatabaseEvent>(
        stream:
            FirebaseDatabase.instance
                .ref('deployed_teams/$teamId/members')
                .onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.children.isEmpty) {
            return const Center(child: Text("No team members found."));
          }

          var members = snapshot.data!.snapshot.children;

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              var member =
                  members.elementAt(index).value as Map<dynamic, dynamic>;
              String ecg = member["ECG"];
              if (ecg.contains("BPM")) {
                int bpm = int.parse(ecg.split(" ")[0]);
                bpm += (DateTime.now().millisecondsSinceEpoch % 7) - 3;
                ecg = "$bpm BPM";
              }

              Color statusColor;
              switch (member["status"]) {
                case "Active":
                  statusColor = Colors.green;
                  break;
                case "Standby":
                  statusColor = Colors.orange;
                  break;
                case "Inactive":
                  statusColor = Colors.red;
                  break;
                default:
                  statusColor = Colors.grey;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor,
                    child: Text(
                      member["name"][0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(member["name"]),
                  subtitle: Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red, size: 16),
                      Text(" $ecg | Status: ${member["status"]}"),
                    ],
                  ),
                  children: [
                    if (member.containsKey("location") &&
                        member["location"] is Map &&
                        member["location"].containsKey("lat") &&
                        member["location"].containsKey("long"))
                      SizedBox(
                        height: 200,
                        child: _buildMemberLocationMap(
                          member["location"]["lat"],
                          member["location"]["long"],
                          member["name"],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person_add),
        onPressed: () {
          _showAddMemberDialog(context);
        },
      ),
    );
  }

  Widget _buildMemberLocationMap(double lat, double long, String memberName) {
    return FlutterMap(
      options: MapOptions(initialCenter: LatLng(lat, long), initialZoom: 13.0),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(lat, long),
              width: 80,
              height: 80,
              child: const Icon(Icons.location_on, color: Colors.red, size: 30),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final nameController = TextEditingController();
    String statusValue = "Active";

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Team Member'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Member Name',
                    hintText: 'Enter member name',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: statusValue,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items:
                      ["Active", "Standby", "Inactive"].map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      statusValue = value;
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    _addNewMember(nameController.text, statusValue);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Member'),
              ),
            ],
          ),
    );
  }

  void _addNewMember(String name, String status) async {
    try {
      double randomLat =
          28.7041 + (DateTime.now().millisecondsSinceEpoch % 100) / 10000;
      double randomLong =
          77.1025 + (DateTime.now().millisecondsSinceEpoch % 100) / 10000;

      await FirebaseDatabase.instance
          .ref('deployed_teams/$teamId/members')
          .push()
          .set({
            'name': name,
            'ECG': '${70 + (DateTime.now().millisecondsSinceEpoch % 20)} BPM',
            'location': {'lat': randomLat, 'long': randomLong},
            'status': status,
          });
      print('Team member added successfully');
    } catch (e) {
      print('Error adding team member: $e');
    }
  }
}
