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
        stream: FirebaseDatabase.instance.ref('deployed_teams').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.children.isEmpty) {
            return const Center(child: Text("No teams deployed yet!"));
          }

          var teams = snapshot.data!.snapshot.children;

          return ListView.builder(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              var team = teams.elementAt(index).value as Map<dynamic, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(team["name"]),
                  subtitle: Text("Location: ${team["location"]}"),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TeamDetailsPage(
                              teamId: teams.elementAt(index).key!,
                              teamName: team["name"],
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
    final nameController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Team'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Team Name',
                    hintText: 'Enter team name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Enter team location',
                  ),
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
                      locationController.text.isNotEmpty) {
                    _addNewTeam(nameController.text, locationController.text);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Team'),
              ),
            ],
          ),
    );
  }

  void _addNewTeam(String name, String location) async {
    try {
      await FirebaseDatabase.instance.ref('deployed_teams').push().set({
        'name': name,
        'location': location,
      });
      print('Team added successfully');
    } catch (e) {
      print('Error adding team: $e');
    }
  }
}
