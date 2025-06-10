import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gsc/app/central/common/translatable_text.dart';

import 'package:gsc/app/central/modules/inventory/inventory_update_page.dart';
import 'package:gsc/app/central/modules/inventory/inventory_request_page.dart';
import 'package:gsc/app/central/modules/inventory/inventory_page.dart';


class VendorListPage extends StatelessWidget {
  final CollectionReference vendorsCollection = 
      FirebaseFirestore.instance.collection('vendors');

  Future<void> toggleVendorStatus(String vendorId, bool currentStatus) async {
    try {
      await vendorsCollection.doc(vendorId).update({
        'isActive': !currentStatus,
      });
    } catch (e) {
      print("Error updating vendor status: $e");
    }
  }

  Future<void> deleteVendor(String vendorId, BuildContext context) async {
    try {
      await vendorsCollection.doc(vendorId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: TranslatableText("Vendor deleted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: TranslatableText("Error deleting vendor: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TranslatableText("Registered Vendors"),
        backgroundColor: Colors.blueGrey,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: vendorsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  TranslatableText(
                    "No vendors registered yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          var vendors = snapshot.data!.docs;

          return ListView.builder(
            itemCount: vendors.length,
            itemBuilder: (context, index) {
              var vendor = vendors[index];
              var vendorData = vendor.data() as Map<String, dynamic>;
              String vendorId = vendor.id;
              
              List<String> suppliedItems = List<String>.from(
                vendorData['suppliedItems'] ?? []
              );
              
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  title: Text(
                    vendorData['name'] ?? 'Unknown Vendor',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: vendorData['isActive'] == true 
                          ? Colors.green[700] 
                          : Colors.red[700],
                    ),
                  ),
                  subtitle: Text(vendorData['contact'] ?? ''),
                  leading: CircleAvatar(
                    backgroundColor: vendorData['isActive'] == true 
                        ? Colors.green 
                        : Colors.red,
                    child: Icon(
                      vendorData['isActive'] == true 
                          ? Icons.store 
                          : Icons.store_outlined,
                      color: Colors.white,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.email, size: 16, color: Colors.grey),
                              SizedBox(width: 8),
                              Text(vendorData['email'] ?? 'No email'),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.grey),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(vendorData['address'] ?? 'No address'),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Supplied Items:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            children: suppliedItems.map((item) => Chip(
                              label: Text(item),
                              backgroundColor: Colors.blue[100],
                            )).toList(),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => toggleVendorStatus(
                                  vendorId, 
                                  vendorData['isActive'] == true
                                ),
                                icon: Icon(
                                  vendorData['isActive'] == true 
                                      ? Icons.pause 
                                      : Icons.play_arrow
                                ),
                                label: Text(
                                  vendorData['isActive'] == true 
                                      ? "Deactivate" 
                                      : "Activate"
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: vendorData['isActive'] == true 
                                      ? Colors.orange 
                                      : Colors.green,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => deleteVendor(vendorId, context),
                                icon: Icon(Icons.delete),
                                label: Text("Delete"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
