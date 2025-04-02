import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'team_details_page.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Deployed Teams',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
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
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[800]!),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.children.isEmpty) {
            return Center(
              child: Text(
                "No teams deployed yet!",
                style: TextStyle(color: Colors.grey[800], fontSize: 18),
              ),
            );
          }

          var teams =
              snapshot.data!.snapshot.children
                  .map((e) => MapEntry(e.key!, e.value))
                  .toList()
                  .cast<MapEntry<String, dynamic>>();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              var team = teams.elementAt(index).value as Map<dynamic, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(
                        255,
                        101,
                        98,
                        98,
                      ).withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    team["name"] ?? "TeamX",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        "Location: ${team["location"] ?? "Unknown"}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Members: ${team["members"]?.length ?? 0}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward, color: Colors.grey[800]),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TeamDetailsPage(
                              teamId: teams.elementAt(index).key!,
                              teamName: team["name"],
                              teamLocation: team["location"],
                              members: team["members"] ?? [],
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
        return Dialog(
          backgroundColor: const Color.fromARGB(255, 109, 102, 102),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Team',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    hintText: 'Enter team location',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[800]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[900],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      _showAddMemberDialog(context, members);
                    },
                    child: const Text(
                      'Add Members',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (locationController.text.isNotEmpty &&
                            members.isNotEmpty) {
                          _addNewTeam(locationController.text, members);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Add Team',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddMemberDialog(
    BuildContext context,
    List<Map<String, dynamic>> members,
  ) {
    final teamNameController = TextEditingController();
    final nameController = TextEditingController();
    final ecgController = TextEditingController();
    final statusController = TextEditingController();
    final latController = TextEditingController();
    final longController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color.fromARGB(255, 143, 140, 140),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Member',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 44, 43, 43),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller:
                      teamNameController, // New controller for team name
                  decoration: InputDecoration(
                    labelText: 'Team Name',
                    labelStyle: TextStyle(
                      color: const Color.fromARGB(255, 28, 26, 26),
                    ),
                    hintText: 'Enter team name',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[800]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Member Name',
                    labelStyle: TextStyle(
                      color: const Color.fromARGB(255, 28, 26, 26),
                    ),
                    hintText: 'Enter member name',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[800]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ecgController,
                  decoration: InputDecoration(
                    labelText: 'ECG',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    hintText: 'Enter ECG (e.g., 75 BPM)',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[800]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: statusController,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    hintText: 'Enter status (e.g., Active)',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[800]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: latController,
                  decoration: InputDecoration(
                    labelText: 'Latitude',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    hintText: 'Enter latitude',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[800]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: longController,
                  decoration: InputDecoration(
                    labelText: 'Longitude',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    hintText: 'Enter longitude',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[800]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (teamNameController.text.isNotEmpty &&
                            nameController.text.isNotEmpty &&
                            ecgController.text.isNotEmpty &&
                            statusController.text.isNotEmpty &&
                            latController.text.isNotEmpty &&
                            longController.text.isNotEmpty) {
                          members.add({
                            "team_name":
                                teamNameController.text, // Added team name
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
                      child: const Text(
                        'Add Member',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
