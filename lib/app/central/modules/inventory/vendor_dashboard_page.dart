import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gsc/app/central/common/translatable_text.dart';

class VendorDashboardPage extends StatefulWidget {
  @override
  _VendorDashboardPageState createState() => _VendorDashboardPageState();
}

class _VendorDashboardPageState extends State<VendorDashboardPage> {
  String? currentVendorId;
  Map<String, dynamic>? vendorData;

  @override
  void initState() {
    super.initState();
    getCurrentVendor();
  }

  Future<void> getCurrentVendor() async {
    try {
      String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      print("Current user email: $userEmail"); // Debug log

      QuerySnapshot vendorQuery = await FirebaseFirestore.instance
          .collection('vendors')
          .where('email', isEqualTo: userEmail)
          .get();

      print("Vendor query results: ${vendorQuery.docs.length}"); // Debug log

      if (vendorQuery.docs.isNotEmpty) {
        setState(() {
          currentVendorId = vendorQuery.docs.first.id;
          vendorData = vendorQuery.docs.first.data() as Map<String, dynamic>;
        });
        print("Current vendor ID: $currentVendorId"); // Debug log
      } else {
        print("No vendor found for email: $userEmail"); // Debug log
        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No vendor account found for this email")),
        );
      }
    } catch (e) {
      print("Error getting vendor: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading vendor data: $e")),
      );
    }
  }

  Future<void> fulfillRequest(String requestId, String vendorRequestId,
      String itemName, int quantity) async {
    try {
      // Show confirmation dialog
      bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm Fulfillment"),
            content: Text("Are you sure you want to fulfill this request for $quantity $itemName?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Cancel", style: TextStyle(color: Color(0xFF3789BB))),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Confirm", style: TextStyle(color: Color(0xFF1A324C))),
              ),
            ],
          );
        },
      ) ?? false;

      if (!confirm) return;

      // Update vendor request status
      await FirebaseFirestore.instance
          .collection('vendor_requests')
          .doc(vendorRequestId)
          .update({
        'status': 'fulfilled',
        'fulfilledAt': FieldValue.serverTimestamp(),
      });

      // Update main supply request status
      await FirebaseFirestore.instance
          .collection('supply_requests')
          .doc(requestId)
          .update({
        'status': 'fulfilled',
        'fulfilledAt': FieldValue.serverTimestamp(),
        'fulfilledBy': currentVendorId,
      });

      // Update inventory stock
      CollectionReference inventoryCollection =
      FirebaseFirestore.instance.collection('inventory');

      QuerySnapshot existingItemQuery = await inventoryCollection
          .where('name', isEqualTo: itemName)
          .get();

      if (existingItemQuery.docs.isNotEmpty) {
        DocumentSnapshot existingDoc = existingItemQuery.docs.first;
        int currentQuantity = (existingDoc['quantity'] as num).toInt();

        await inventoryCollection.doc(existingDoc.id).update({
          'quantity': currentQuantity + quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await inventoryCollection.add({
          'name': itemName,
          'quantity': quantity,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: TranslatableText("Request fulfilled successfully!")),
      );

    } catch (e) {
      print("Error fulfilling request: $e"); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: TranslatableText("Error fulfilling request: $e")),
      );
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print("Error logging out: $e");
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
        child: currentVendorId == null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A324C)),
              ),
              SizedBox(height: 16),
              Text(
                "Loading vendor data...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: getCurrentVendor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5F6898),
                  foregroundColor: Colors.white,
                ),
                child: Text("Retry"),
              ),
            ],
          ),
        )
            : Column(
          children: [
            // Vendor Info Card
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF3789BB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, ${vendorData?['name'] ?? 'Vendor'}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A324C),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Contact: ${vendorData?['contact'] ?? 'N/A'}",
                    style: TextStyle(color: Color(0xFF3789BB)),
                  ),
                  Text(
                    "Email: ${vendorData?['email'] ?? 'N/A'}",
                    style: TextStyle(color: Color(0xFF3789BB)),
                  ),
                  Text(
                    "Vendor ID: $currentVendorId", // Debug info
                    style: TextStyle(color: Color(0xFF5F6898), fontSize: 12),
                  ),
                ],
              ),
            ),

            // Debug section - remove this in production
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFF5F6898).withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Debug Info:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A324C),
                    ),
                  ),
                  Text(
                    "Vendor ID: $currentVendorId",
                    style: TextStyle(color: Color(0xFF3789BB)),
                  ),
                  Text(
                    "User Email: ${FirebaseAuth.instance.currentUser?.email ?? 'Not logged in'}",
                    style: TextStyle(color: Color(0xFF3789BB)),
                  ),
                ],
              ),
            ),

            // Pending Requests Section
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.pending_actions, color: Color(0xFF3789BB)),
                  SizedBox(width: 8),
                  Text(
                    "Pending Government Requests",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Requests List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: currentVendorId != null
                    ? FirebaseFirestore.instance
                    .collection('vendor_requests')
                    .where('vendorId', isEqualTo: currentVendorId)
                    .orderBy('sentAt', descending: true)
                    .snapshots()
                    : null,
                builder: (context, snapshot) {
                  if (currentVendorId == null) {
                    return Center(
                      child: Text(
                        "Vendor ID not found",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A324C)),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 64, color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            "Error loading requests: ${snapshot.error}",
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => setState(() {}), // Refresh
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF5F6898),
                              foregroundColor: Colors.white,
                            ),
                            child: Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.white.withOpacity(0.7)),
                          SizedBox(height: 16),
                          TranslatableText(
                            "No requests found",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Looking for requests for vendor: $currentVendorId",
                            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var request = snapshot.data!.docs[index];
                      var requestData = request.data() as Map<String, dynamic>;

                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 8,
                        color: Colors.white.withOpacity(0.95),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.shopping_cart,
                                    color: _getPriorityColor(requestData['priority']),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      requestData['itemName'] ?? 'Unknown Item',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A324C),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(requestData['priority']),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      requestData['priority'] ?? 'Medium',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.numbers, size: 16, color: Color(0xFF3789BB)),
                                  SizedBox(width: 4),
                                  Text(
                                    "Quantity: ${requestData['quantity']}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF1A324C),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.info, size: 16, color: Color(0xFF3789BB)),
                                  SizedBox(width: 4),
                                  Text(
                                    "Status: ${requestData['status'] ?? 'sent'}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF5F6898),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 16, color: Color(0xFF3789BB)),
                                  SizedBox(width: 4),
                                  Text(
                                    "Requested: ${_formatTimestamp(requestData['sentAt'])}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF5F6898),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              if (requestData['status'] != 'fulfilled')
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => fulfillRequest(
                                      requestData['requestId'],
                                      request.id,
                                      requestData['itemName'],
                                      requestData['quantity'],
                                    ),
                                    icon: Icon(Icons.check_circle),
                                    label: Text("Fulfill Request"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF5F6898),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF3789BB).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Color(0xFF3789BB)),
                                  ),
                                  child: Text(
                                    "✓ Fulfilled",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF1A324C),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: TranslatableText(
          "Vendor Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1A324C),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF3789BB)),
            onPressed: getCurrentVendor, // Refresh vendor data
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Color(0xFF3789BB)),
            onPressed: logout,
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Color(0xFF3789BB); // Using dashboard blue for medium priority
      case 'low':
        return Color(0xFF5F6898); // Using dashboard button color for low priority
      default:
        return Color(0xFF3789BB);
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';

    DateTime dateTime = timestamp.toDate();
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}