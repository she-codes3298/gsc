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
        SnackBar(content: TranslatableText("Please enter a valid item and quantity")),
      );
      return;
    }

    try {
      // Get relevant vendors for this item
      List<Map<String, dynamic>> relevantVendors = await getRelevantVendors(itemName);

      if (relevantVendors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: TranslatableText("No active vendors found for this item. Try a different item name.")),
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
          backgroundColor: Colors.green,
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
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showVendorDetails(List<Map<String, dynamic>> vendors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Request Sent To Vendors"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: vendors.length,
              itemBuilder: (context, index) {
                var vendor = vendors[index];
                return ListTile(
                  title: Text(vendor['name']),
                  subtitle: Text("Contact: ${vendor['contact']}\nEmail: ${vendor['email']}"),
                  leading: Icon(Icons.store, color: Colors.green),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
      appBar: AppBar(
        title: const TranslatableText("Request Supplies"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Help text
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "💡 Tips:",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
                  ),
                  Text(
                    "• Use general terms like 'Water', 'Food', 'Medical'\n• System will find vendors that supply similar items\n• Multiple vendors may receive your request",
                    style: TextStyle(color: Colors.blue[700], fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Item Name",
                border: OutlineInputBorder(),
                helperText: "e.g., Water Bottles, Medical Kits, Food Packets",
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: InputDecoration(
                labelText: "Priority Level",
                border: OutlineInputBorder(),
              ),
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
                      Text(priority),
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
                backgroundColor: Colors.blueGrey,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const TranslatableText(
                "Send Request to Vendors",
                style: TextStyle(fontSize: 16, color: Colors.white),
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
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: TranslatableText("No recent requests"),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TranslatableText(
                        "Recent Requests",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var request = snapshot.data!.docs[index];
                            var requestData = request.data() as Map<String, dynamic>;

                            return Card(
                              child: ListTile(
                                title: Text(requestData['itemName'] ?? 'Unknown Item'),
                                subtitle: Text(
                                    "Qty: ${requestData['quantity']} | Priority: ${requestData['priority']}\nVendors: ${(requestData['vendorIds'] as List?)?.length ?? 0}"
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
                                        ? Colors.green
                                        : Colors.grey,
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
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}