import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gsc/app/central/common/translatable_text.dart';

class InventoryRequestPage extends StatefulWidget {
  final List<Map<String, dynamic>> availableItems;

  const InventoryRequestPage({Key? key, required this.availableItems}) : super(key: key);

  @override
  _InventoryRequestPageState createState() => _InventoryRequestPageState();
}

class _InventoryRequestPageState extends State<InventoryRequestPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  String _selectedPriority = 'Medium';
  List<String> _priorities = ['Low', 'Medium', 'High', 'Critical'];

  Future<List<Map<String, dynamic>>> getRelevantVendors(String itemName) async {
    try {
      QuerySnapshot vendorSnapshot = await FirebaseFirestore.instance
          .collection('vendors')
          .where('isActive', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> relevantVendors = [];

      for (var doc in vendorSnapshot.docs) {
        var vendorData = doc.data() as Map<String, dynamic>;
        List<String> suppliedItems = List<String>.from(vendorData['suppliedItems'] ?? []);

        // Check if vendor supplies this item (case insensitive)
        bool suppliesItem = suppliedItems.any((suppliedItem) =>
        suppliedItem.toLowerCase().contains(itemName.toLowerCase()) ||
            itemName.toLowerCase().contains(suppliedItem.toLowerCase())
        );

        if (suppliesItem) {
          relevantVendors.add({
            'id': doc.id,
            'name': vendorData['name'],
            'contact': vendorData['contact'],
            'email': vendorData['email'],
            'suppliedItems': suppliedItems,
          });
        }
      }

      print("Found ${relevantVendors.length} relevant vendors for '$itemName'"); // Debug log
      return relevantVendors;
    } catch (e) {
      print("Error getting vendors: $e");
      return [];
    }
  }

  Future<void> requestItem() async {
    String itemName = _nameController.text.trim();
    int requestedQuantity = int.tryParse(_quantityController.text) ?? 0;

    if (itemName.isEmpty || requestedQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TranslatableText("Please enter a valid item and quantity"),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }

    try {
      // Get relevant vendors for this item
      List<Map<String, dynamic>> relevantVendors = await getRelevantVendors(itemName);

      if (relevantVendors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: TranslatableText("No active vendors found for this item. Try a different item name."),
            backgroundColor: Colors.red[400],
          ),
        );
        return;
      }

      // Create main supply request first
      DocumentReference requestRef = await FirebaseFirestore.instance
          .collection('supply_requests')
          .add({
        'itemName': itemName,
        'quantity': requestedQuantity,
        'priority': _selectedPriority,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
        'vendorIds': relevantVendors.map((v) => v['id']).toList(),
      });

      print("Created main request: ${requestRef.id}"); // Debug log

      // Send individual requests to each relevant vendor
      List<Future> vendorRequestFutures = [];

      for (var vendor in relevantVendors) {
        print("Creating vendor request for vendor: ${vendor['id']} (${vendor['name']})"); // Debug log

        vendorRequestFutures.add(
            FirebaseFirestore.instance
                .collection('vendor_requests')
                .add({
              'requestId': requestRef.id,
              'vendorId': vendor['id'],
              'vendorName': vendor['name'],
              'itemName': itemName,
              'quantity': requestedQuantity,
              'priority': _selectedPriority,
              'status': 'sent', // Make sure this is set
              'sentAt': FieldValue.serverTimestamp(),
              'createdAt': FieldValue.serverTimestamp(), // Additional timestamp
            })
        );
      }

      // Wait for all vendor requests to be created
      await Future.wait(vendorRequestFutures);

      print("Created ${relevantVendors.length} vendor requests"); // Debug log

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TranslatableText("Request sent to ${relevantVendors.length} vendor(s) successfully!"),
          backgroundColor: const Color(0xFF3789BB),
        ),
      );

      // Show vendor details
      _showVendorDetails(relevantVendors);

      // Clear the input fields
      _nameController.clear();
      _quantityController.clear();
      setState(() {
        _selectedPriority = 'Medium';
      });

    } catch (e) {
      print("Error in requestItem: $e"); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TranslatableText("Error sending request: $e"),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  void _showVendorDetails(List<Map<String, dynamic>> vendors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Request Sent To Vendors",
            style: TextStyle(color: const Color(0xFF1A324C), fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: vendors.length,
              itemBuilder: (context, index) {
                var vendor = vendors[index];
                return ListTile(
                  title: Text(
                    vendor['name'],
                    style: TextStyle(color: const Color(0xFF1A324C), fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "Contact: ${vendor['contact']}\nEmail: ${vendor['email']}",
                    style: TextStyle(color: const Color(0xFF5F6898)),
                  ),
                  leading: Icon(Icons.store, color: const Color(0xFF3789BB)),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF3789BB),
                foregroundColor: Colors.white,
              ),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
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
              Color(0xFF87CEEB), // Sky Blue - lighter and more vibrant
              Color(0xFF4682B4), // Steel Blue - professional yet lighter
            ],
            stops: [0.3, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Help text
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF3789BB).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "💡 Tips:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A324C)
                      ),
                    ),
                    Text(
                      "• Use general terms like 'Water', 'Food', 'Medical'\n• System will find vendors that supply similar items\n• Multiple vendors may receive your request",
                      style: TextStyle(
                          color: const Color(0xFF5F6898),
                          fontSize: 12
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              TextField(
                controller: _nameController,
                style: TextStyle(color: const Color(0xFF1A324C)),
                decoration: InputDecoration(
                  labelText: "Item Name",
                  labelStyle: TextStyle(color: const Color(0xFF5F6898)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF3789BB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF3789BB).withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF3789BB), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  helperText: "e.g., Water Bottles, Medical Kits, Food Packets",
                  helperStyle: TextStyle(color: const Color(0xFF5F6898)),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                style: TextStyle(color: const Color(0xFF1A324C)),
                decoration: InputDecoration(
                  labelText: "Quantity",
                  labelStyle: TextStyle(color: const Color(0xFF5F6898)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF3789BB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF3789BB).withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF3789BB), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                style: TextStyle(color: const Color(0xFF1A324C)),
                decoration: InputDecoration(
                  labelText: "Priority Level",
                  labelStyle: TextStyle(color: const Color(0xFF5F6898)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF3789BB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF3789BB).withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF3789BB), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                ),
                dropdownColor: Colors.white,
                items: _priorities.map((String priority) {
                  return DropdownMenuItem<String>(
                    value: priority,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(priority),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(priority, style: TextStyle(color: const Color(0xFF1A324C))),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPriority = newValue!;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: requestItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5F6898),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const TranslatableText(
                  "Send Request to Vendors",
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('supply_requests')
                      .orderBy('requestedAt', descending: true)
                      .limit(10) // Limit to recent requests
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF3789BB)),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: TranslatableText(
                          "No recent requests",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TranslatableText(
                          "Recent Requests",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var request = snapshot.data!.docs[index];
                              var requestData = request.data() as Map<String, dynamic>;

                              return Card(
                                color: Colors.white.withOpacity(0.95),
                                elevation: 3,
                                margin: EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  title: Text(
                                    requestData['itemName'] ?? 'Unknown Item',
                                    style: TextStyle(
                                      color: const Color(0xFF1A324C),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Qty: ${requestData['quantity']} | Priority: ${requestData['priority']}\nVendors: ${(requestData['vendorIds'] as List?)?.length ?? 0}",
                                    style: TextStyle(color: const Color(0xFF5F6898)),
                                  ),
                                  leading: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(requestData['priority']),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: requestData['status'] == 'pending'
                                          ? Colors.orange
                                          : requestData['status'] == 'fulfilled'
                                          ? const Color(0xFF3789BB)
                                          : const Color(0xFF5F6898),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      requestData['status'] ?? 'unknown',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const TranslatableText(
          "Request Supplies",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A324C),
        iconTheme: const IconThemeData(color: Colors.white),
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
        return const Color(0xFF3789BB);
      case 'low':
        return Colors.green;
      default:
        return const Color(0xFF3789BB);
    }
  }
}