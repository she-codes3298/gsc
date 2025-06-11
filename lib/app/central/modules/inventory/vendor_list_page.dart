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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            transform: GradientRotation(-40 * 3.14159 / 180), // -40 degrees in radians
            colors: [
              Color(0xFF87CEEB), // Sky Blue - matching dashboard
              Color(0xFF4682B4), // Steel Blue - matching dashboard
            ],
            stops: [0.3, 1.0],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: vendorsCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A324C)),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store_outlined, size: 64, color: Colors.white.withOpacity(0.7)),
                    SizedBox(height: 16),
                    TranslatableText(
                      "No vendors registered yet",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              );
            }

            var vendors = snapshot.data!.docs;

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: vendors.length,
              itemBuilder: (context, index) {
                var vendor = vendors[index];
                var vendorData = vendor.data() as Map<String, dynamic>;
                String vendorId = vendor.id;

                List<String> suppliedItems = List<String>.from(
                    vendorData['suppliedItems'] ?? []
                );

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 8,
                  color: Colors.white.withOpacity(0.95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      vendorData['name'] ?? 'Unknown Vendor',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: vendorData['isActive'] == true
                            ? Color(0xFF3789BB)
                            : Colors.red[700],
                      ),
                    ),
                    subtitle: Text(
                      vendorData['contact'] ?? '',
                      style: TextStyle(color: Color(0xFF5F6898)),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: vendorData['isActive'] == true
                          ? Color(0xFF3789BB)
                          : Colors.red,
                      child: Icon(
                        vendorData['isActive'] == true
                            ? Icons.store
                            : Icons.store_outlined,
                        color: Colors.white,
                      ),
                    ),
                    collapsedIconColor: Color(0xFF1A324C),
                    iconColor: Color(0xFF1A324C),
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.email, size: 16, color: Color(0xFF3789BB)),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    vendorData['email'] ?? 'No email',
                                    style: TextStyle(color: Color(0xFF1A324C)),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.location_on, size: 16, color: Color(0xFF3789BB)),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    vendorData['address'] ?? 'No address',
                                    style: TextStyle(color: Color(0xFF1A324C)),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Supplied Items:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A324C),
                              ),
                            ),
                            SizedBox(height: 8),
                            suppliedItems.isNotEmpty
                                ? Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: suppliedItems.map((item) => Chip(
                                label: Text(
                                  item,
                                  style: TextStyle(
                                    color: Color(0xFF1A324C),
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: Color(0xFF3789BB).withOpacity(0.2),
                                side: BorderSide(color: Color(0xFF3789BB), width: 1),
                              )).toList(),
                            )
                                : Text(
                              "No items specified",
                              style: TextStyle(
                                color: Color(0xFF5F6898),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => toggleVendorStatus(
                                        vendorId,
                                        vendorData['isActive'] == true
                                    ),
                                    icon: Icon(
                                      vendorData['isActive'] == true
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      size: 18,
                                    ),
                                    label: Text(
                                      vendorData['isActive'] == true
                                          ? "Deactivate"
                                          : "Activate",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: vendorData['isActive'] == true
                                          ? Colors.orange
                                          : Color(0xFF3789BB),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showDeleteConfirmation(context, vendorId, vendorData['name'] ?? 'this vendor'),
                                    icon: Icon(Icons.delete, size: 18),
                                    label: Text(
                                      "Delete",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
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
      ),
      appBar: AppBar(
        title: TranslatableText(
          "Registered Vendors",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1A324C),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF3789BB)),
            onPressed: () {
              // Refresh will happen automatically due to StreamBuilder
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String vendorId, String vendorName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete Vendor",
            style: TextStyle(color: Color(0xFF1A324C)),
          ),
          content: Text(
            "Are you sure you want to delete $vendorName? This action cannot be undone.",
            style: TextStyle(color: Color(0xFF5F6898)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(color: Color(0xFF3789BB)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteVendor(vendorId, context);
              },
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}