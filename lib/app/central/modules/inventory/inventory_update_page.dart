import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gsc/app/central/common/translatable_text.dart';

class InventoryUpdatePage extends StatefulWidget {
  final String itemId; // Item's Firestore document ID
  final String initialName;
  final int initialQuantity;

  const InventoryUpdatePage({
    required this.itemId,
    required this.initialName,
    required this.initialQuantity,
    Key? key,
  }) : super(key: key);

  @override
  _InventoryUpdatePageState createState() => _InventoryUpdatePageState();
}

class _InventoryUpdatePageState extends State<InventoryUpdatePage> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  final CollectionReference inventoryCollection = FirebaseFirestore.instance
      .collection('inventory');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _quantityController = TextEditingController(
      text: widget.initialQuantity.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

 /* Future<void> updateItem() async {
    String updatedName = _nameController.text;
    int updatedQuantity =
        int.tryParse(_quantityController.text) ?? widget.initialQuantity;
    DocumentReference itemRef = inventoryCollection.doc(widget.itemId);

    try {
      final docSnapshot = await itemRef.get();

      if (docSnapshot.exists) {
        // If the document exists, update it
        await itemRef.update({
          'name': updatedName,
          'quantity': updatedQuantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // If the document does not exist, create it
        await itemRef.set({
          'name': updatedName,
          'quantity': updatedQuantity,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: TranslatableText("Item updated successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: TranslatableText("Error updating item: $e")),
      );
    }
  }*/

  // Function to delete an inventory item
  Future<void> deleteItem(String itemId) async {
    try {
      // Show confirmation dialog before deleting
      bool confirmDelete = await _showDeleteConfirmation(itemId);
      if (!confirmDelete) return;

      await inventoryCollection.doc(itemId).delete();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: TranslatableText("Item deleted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: TranslatableText("Error deleting item: $e")),
      );
    }
  }

  // Confirmation dialog for delete operation
  Future<bool> _showDeleteConfirmation(String itemId) async {
    bool result = false;
    
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: TranslatableText("Confirm Delete"),
          content: TranslatableText("Are you sure you want to delete this inventory item?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                result = false;
              },
              child: TranslatableText("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                result = true;
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
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: TranslatableText("View Stock")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(

            ),
          ),

          Padding(
            padding: EdgeInsets.all(8.0),
            child: TranslatableText(
              "Current Inventory Stock",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: inventoryCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: TranslatableText("No inventory items available."),
                  );
                }

                var inventoryList = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: inventoryList.length,
                  itemBuilder: (context, index) {
                    var item = inventoryList[index];
                    String itemId = item.id;
                    
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(item['name']),
                        subtitle: Text("Stock: ${item['quantity']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Edit button
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InventoryUpdatePage(
                                      itemId: itemId,
                                      initialName: item['name'],
                                      initialQuantity: item['quantity'],
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Delete button
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteItem(itemId),
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
    );
  }
}
