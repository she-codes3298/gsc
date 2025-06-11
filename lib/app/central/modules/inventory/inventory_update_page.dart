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
        SnackBar(
          content: TranslatableText("Item deleted successfully!"),
          backgroundColor: const Color(0xFF3789BB),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TranslatableText("Error deleting item: $e"),
          backgroundColor: Colors.red[400],
        ),
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
          backgroundColor: Colors.white,
          title: TranslatableText(
            "Confirm Delete",
            style: TextStyle(
              color: const Color(0xFF1A324C),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TranslatableText(
            "Are you sure you want to delete this inventory item?",
            style: TextStyle(color: const Color(0xFF5F6898)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                result = false;
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF5F6898),
              ),
              child: TranslatableText("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                result = true;
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
              ),
              child: Text("Delete"),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                // Empty for now, as per original code
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: TranslatableText(
                "Current Inventory Stock",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: inventoryCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TranslatableText(
                          "No inventory items available.",
                          style: TextStyle(
                            color: const Color(0xFF5F6898),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }

                  var inventoryList = snapshot.data!.docs;

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    itemCount: inventoryList.length,
                    itemBuilder: (context, index) {
                      var item = inventoryList[index];
                      String itemId = item.id;

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        elevation: 4,
                        color: Colors.white.withOpacity(0.95),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3789BB).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.inventory_2,
                              color: const Color(0xFF3789BB),
                              size: 24,
                            ),
                          ),
                          title: Text(
                            item['name'],
                            style: TextStyle(
                              color: const Color(0xFF1A324C),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Container(
                            margin: EdgeInsets.only(top: 4),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5F6898).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Stock: ${item['quantity']}",
                              style: TextStyle(
                                color: const Color(0xFF5F6898),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit button
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3789BB).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: const Color(0xFF3789BB),
                                  ),
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
                              ),
                              SizedBox(width: 8),
                              // Delete button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red[400],
                                  ),
                                  onPressed: () => deleteItem(itemId),
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
        title: const TranslatableText(
          "View Stock",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A324C),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
    );
  }
}