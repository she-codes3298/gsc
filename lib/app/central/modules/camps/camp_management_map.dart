import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

class RefugeeCampPage extends StatefulWidget {
  @override
  _RefugeeCampPageState createState() => _RefugeeCampPageState();
}

class _RefugeeCampPageState extends State<RefugeeCampPage> {
  GoogleMapController? _mapController;
  LatLng? selectedLocation;
  Set<Marker> _markers = {};
  List<Map<String, dynamic>> refugeeCamps = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCampsFromFirestore();
  }

  void fetchCampsFromFirestore() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('refugee_camps').get();

      List<Map<String, dynamic>> camps =
          snapshot.docs
              .map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                if (data['location'] is GeoPoint) {
                  GeoPoint location = data['location'];
                  return {
                    'id': doc.id,
                    'name': data['name'] ?? 'Unknown',
                    'location': LatLng(location.latitude, location.longitude),
                    'address': data['address'] ?? 'No Address Available',
                    'capacity': data['capacity'] ?? 0,
                    'current_occupancy': data['current_occupancy'] ?? 0,
                    'resources': data['resources'] ?? 'None',
                    'contact': data['contact'] ?? 'No Contact Available',
                  };
                } else {
                  print(
                    "Error: Invalid location format for document ${doc.id}",
                  );
                  return null;
                }
              })
              .whereType<Map<String, dynamic>>()
              .toList();

      setState(() {
        refugeeCamps = camps;
        _markers =
            camps.map((camp) {
              return Marker(
                markerId: MarkerId(camp['id']),
                position: camp['location'],
                infoWindow: InfoWindow(
                  title: camp['name'],
                  snippet:
                      "Capacity: ${camp['capacity']}, Occupied: ${camp['current_occupancy']}",
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
              );
            }).toSet();
      });
    } catch (e) {
      print("Error fetching refugee camps: $e");
    }
  }

  void addCampToFirestore(
    String name,
    LatLng position,
    String address,
    int capacity,
    int currentOccupancy,
    String resources,
    String contact,
  ) async {
    if (name.isEmpty ||
        address.isEmpty ||
        resources.isEmpty ||
        contact.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("All fields must be filled!")));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('refugee_camps').add({
        'name': name,
        'location': GeoPoint(position.latitude, position.longitude),
        'address': address,
        'capacity': capacity,
        'current_occupancy': currentOccupancy,
        'resources': resources,
        'contact': contact,
      });
      fetchCampsFromFirestore();
    } catch (e) {
      print("Error adding refugee camp: $e");
    }
  }

  void deleteCamp(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('refugee_camps')
          .doc(id)
          .delete();
      fetchCampsFromFirestore();
    } catch (e) {
      print("Error deleting refugee camp: $e");
    }
  }

  void updateCivilians() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('refugee_camps').get();
      List<Map<String, dynamic>> campData =
          snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

      await FirebaseFirestore.instance
          .collection('civilian_data')
          .doc('refugee_camps')
          .set({'camps': campData});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Data sent to civilian!")));
    } catch (e) {
      print("Error updating civilian data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update civilian data.")),
      );
    }
  }

  void showAddCampDialog() {
    if (selectedLocation == null) return;
    TextEditingController nameController = TextEditingController();
    TextEditingController addressController = TextEditingController(
      text: searchController.text,
    );
    TextEditingController capacityController = TextEditingController();
    TextEditingController occupancyController = TextEditingController();
    TextEditingController resourcesController = TextEditingController();
    TextEditingController contactController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Refugee Camp"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Camp Name"),
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: "Address"),
                ),
                TextField(
                  controller: capacityController,
                  decoration: InputDecoration(labelText: "Capacity"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: occupancyController,
                  decoration: InputDecoration(labelText: "Current Occupancy"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: resourcesController,
                  decoration: InputDecoration(labelText: "Resources"),
                ),
                TextField(
                  controller: contactController,
                  decoration: InputDecoration(labelText: "Contact"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                addCampToFirestore(
                  nameController.text,
                  selectedLocation!,
                  addressController.text,
                  int.tryParse(capacityController.text) ?? 0,
                  int.tryParse(occupancyController.text) ?? 0,
                  resourcesController.text,
                  contactController.text,
                );
                Navigator.pop(context);
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
      appBar: AppBar(title: Text("Refugee Camp Management")),
      body: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(labelText: "Search Location"),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(28.7041, 77.1025),
                zoom: 5,
              ),
              markers: _markers,
              onMapCreated: (controller) => _mapController = controller,
              onTap: (LatLng position) async {
                try {
                  List<Placemark> placemarks = await placemarkFromCoordinates(
                    position.latitude,
                    position.longitude,
                  );
                  String address =
                      placemarks.isNotEmpty
                          ? "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.country}"
                          : "Unknown Address";
                  setState(() {
                    selectedLocation = position;
                    searchController.text = address;
                  });
                  showAddCampDialog();
                } catch (e) {
                  print("Error fetching address: $e");
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: updateCivilians,
            child: Text("Send Data to Civilian App"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: refugeeCamps.length,
              itemBuilder: (context, index) {
                final camp = refugeeCamps[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(
                      camp['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Address: ${camp['address']}"),
                        Text(
                          "Capacity: ${camp['capacity']} | Occupied: ${camp['current_occupancy']}",
                        ),
                        Text("Resources: ${camp['resources']}"),
                        Text("Contact: ${camp['contact']}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteCamp(camp['id']),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
