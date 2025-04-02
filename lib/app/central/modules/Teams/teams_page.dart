import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'team_details_page.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deployed Teams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddTeamDialog(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref('teams').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.children.isEmpty) {
            return const Center(child: Text("No teams deployed yet!"));
          }

          var teams =
              snapshot.data!.snapshot.children
                  .map((e) => MapEntry(e.key!, e.value))
                  .toList()
                  .cast<MapEntry<String, dynamic>>();

          return ListView.builder(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              var team = teams.elementAt(index).value as Map<dynamic, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text("Location: ${team["location"]}"),
                  subtitle: Text("Members: ${team["members"]?.length ?? 0}"),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TeamDetailsPage(
                              teamId: teams.elementAt(index).key!,
                              teamName:
                                  team["name"], // Ensure 'name' exists in your data
                              teamLocation:
                                  team["location"], // Ensure 'location' exists in your data
                              members:
                                  team["members"] ??
                                  [], // Ensure 'members' exists in your data
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddTeamDialog(BuildContext context) {
    final locationController = TextEditingController();
    List<Map<String, dynamic>> members = [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Team'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter team location',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _showAddMemberDialog(context, members);
                },
                child: const Text('Add Members'),
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
                if (locationController.text.isNotEmpty && members.isNotEmpty) {
                  _addNewTeam(locationController.text, members);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Team'),
            ),
          ],
        );
      },
    );
  }

  void _showAddMemberDialog(
    BuildContext context,
    List<Map<String, dynamic>> members,
  ) {
    final nameController = TextEditingController();
    final ecgController = TextEditingController();
    final statusController = TextEditingController();
    final latController = TextEditingController();
    final longController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Member'),
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
              TextField(
                controller: ecgController,
                decoration: const InputDecoration(
                  labelText: 'ECG',
                  hintText: 'Enter ECG (e.g., 75 BPM)',
                ),
              ),
              TextField(
                controller: statusController,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  hintText: 'Enter status (e.g., Active)',
                ),
              ),
              TextField(
                controller: latController,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  hintText: 'Enter latitude',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: longController,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  hintText: 'Enter longitude',
                ),
                keyboardType: TextInputType.number,
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
                if (nameController.text.isNotEmpty &&
                    ecgController.text.isNotEmpty &&
                    statusController.text.isNotEmpty &&
                    latController.text.isNotEmpty &&
                    longController.text.isNotEmpty) {
                  members.add({
                    "name": nameController.text,
                    "ECG": ecgController.text,
                    "status": statusController.text,
                    "location": {
                      "lat": double.parse(latController.text),
                      "long": double.parse(longController.text),
                    },
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text('Add Member'),
            ),
          ],
        );
      },
    );
  }

  void _addNewTeam(String location, List<Map<String, dynamic>> members) async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref('teams').push();

      await ref.set({'location': location, 'members': members});

      print('Team added successfully');
    } catch (e) {
      print('Error adding team: $e');
    }
  }
}
