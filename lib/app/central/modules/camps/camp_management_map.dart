import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:gsc/app/central/common/translatable_text.dart';
import 'package:gsc/services/translation_service.dart';

class RefugeeCampPage extends StatefulWidget {
  const RefugeeCampPage({super.key});

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

      List<Map<String, dynamic>> camps = snapshot.docs
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
          print("Error: Invalid location format for document ${doc.id}");
          return null;
        }
      })
          .whereType<Map<String, dynamic>>()
          .toList();

      setState(() {
        refugeeCamps = camps;
        _markers = camps
            .map((camp) {
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
        })
            .toSet();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const TranslatableText("All fields must be filled!"),
          backgroundColor: const Color(0xFF1A324C),
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const TranslatableText("Camp added successfully!"),
          backgroundColor: const Color(0xFF3789BB),
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const TranslatableText("Camp deleted successfully!"),
          backgroundColor: const Color(0xFF3789BB),
        ),
      );
    } catch (e) {
      print("Error deleting refugee camp: $e");
    }
  }

  void updateCivilians() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('refugee_camps').get();
      List<Map<String, dynamic>> campData = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      await FirebaseFirestore.instance
          .collection('civilian_data')
          .doc('refugee_camps')
          .set({'camps': campData});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const TranslatableText("Data sent to civilian!"),
          backgroundColor: const Color(0xFF3789BB),
        ),
      );
    } catch (e) {
      print("Error updating civilian data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const TranslatableText("Failed to update civilian data."),
          backgroundColor: const Color(0xFF1A324C),
        ),
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const TranslatableText(
            "Add Refugee Camp",
            style: TextStyle(
              color: Color(0xFF1A324C),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildDialogTextField(nameController, "Camp Name", Icons.home),
                const SizedBox(height: 12),
                _buildDialogTextField(addressController, "Address", Icons.location_on),
                const SizedBox(height: 12),
                _buildDialogTextField(capacityController, "Capacity", Icons.people, isNumber: true),
                const SizedBox(height: 12),
                _buildDialogTextField(occupancyController, "Current Occupancy", Icons.person, isNumber: true),
                const SizedBox(height: 12),
                _buildDialogTextField(resourcesController, "Resources", Icons.inventory),
                const SizedBox(height: 12),
                _buildDialogTextField(contactController, "Contact", Icons.phone),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const TranslatableText(
                "Cancel",
                style: TextStyle(color: Color(0xFF1A324C)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3789BB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
              child: const TranslatableText(
                "Add",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool isNumber = false,
      }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF3789BB)),
        prefixIcon: Icon(icon, color: const Color(0xFF3789BB)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3789BB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3789BB), width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TranslatableText(
          "Refugee Camp Management",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A324C),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            transform: GradientRotation(-40 * 3.14159 / 180),
            colors: [
              Color(0xFF87CEEB), // Sky Blue - matching inventory page
              Color(0xFF4682B4), // Steel Blue - matching inventory page
            ],
            stops: [0.3, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Stats Card Section
            Container(
              margin: const EdgeInsets.all(16),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white.withOpacity(0.95),
                child: ListTile(
                  title: const TranslatableText(
                    "Total Refugee Camps",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A324C),
                    ),
                  ),
                  subtitle: TranslatableText(
                    "${refugeeCamps.length} Camps",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF3789BB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3789BB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.home,
                      color: Color(0xFF3789BB),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),

            // Search Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: "Search Location",
                    labelStyle: const TextStyle(color: Color(0xFF3789BB)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF3789BB)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Map Section
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
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
                        String address = placemarks.isNotEmpty
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
              ),
            ),

            const SizedBox(height: 16),

            // Send Data Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3789BB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                onPressed: updateCivilians,
                child: const TranslatableText(
                  "Send Data to Civilian App",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Camps List Section
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: refugeeCamps.isEmpty
                    ? const Center(
                  child: TranslatableText(
                    "No refugee camps found. Tap on the map to add one.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
                    : ListView.builder(
                  itemCount: refugeeCamps.length,
                  itemBuilder: (context, index) {
                    final camp = refugeeCamps[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white.withOpacity(0.95),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3789BB).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.home,
                              color: Color(0xFF3789BB),
                              size: 28,
                            ),
                          ),
                          title: TranslatableText(
                            camp['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF1A324C),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TranslatableText(
                                  "📍 ${camp['address']}",
                                  style: const TextStyle(
                                    color: Color(0xFF3789BB),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TranslatableText(
                                  "👥 Capacity: ${camp['capacity']} | Occupied: ${camp['current_occupancy']}",
                                  style: const TextStyle(
                                    color: Color(0xFF1A324C),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TranslatableText(
                                  "📦 Resources: ${camp['resources']}",
                                  style: const TextStyle(
                                    color: Color(0xFF3789BB),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TranslatableText(
                                  "📞 Contact: ${camp['contact']}",
                                  style: const TextStyle(
                                    color: Color(0xFF3789BB),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteCamp(camp['id']),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}