import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CampManagementMap extends StatefulWidget {
  @override
  _CampManagementMapState createState() => _CampManagementMapState();
}

class _CampManagementMapState extends State<CampManagementMap> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _fetchCamps();
  }

  void _fetchCamps() async {
    FirebaseFirestore.instance.collection('refugee_camps').get().then((
      snapshot,
    ) {
      snapshot.docs.forEach((doc) {
        GeoPoint location = doc['location'];
        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(location.latitude, location.longitude),
              infoWindow: InfoWindow(title: doc['name']),
            ),
          );
        });
      });
    });
  }

  void _addCamp(LatLng position) {
    FirebaseFirestore.instance.collection('refugee_camps').add({
      'name': 'New Refugee Camp',
      'location': GeoPoint(position.latitude, position.longitude),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Camps')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(20.5937, 78.9629),
          zoom: 5,
        ),
        markers: _markers,
        onLongPress: _addCamp, // Long press to add a new refugee center
      ),
    );
  }
}
