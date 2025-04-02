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
      // Reference to Firestore collection
      CollectionReference inventoryCollection = FirebaseFirestore.instance.collection('inventory');

      // Create the inventory collection if it doesn't exist (Firestore creates it automatically)
      QuerySnapshot existingItemQuery =
      await inventoryCollection.where('name', isEqualTo: itemName).get();

      if (existingItemQuery.docs.isNotEmpty) {
        // If item exists, update the quantity
        DocumentSnapshot existingDoc = existingItemQuery.docs.first;
        String existingItemId = existingDoc.id;
        int currentQuantity = (existingDoc['quantity'] as num).toInt(); // Ensure integer type

        await inventoryCollection.doc(existingItemId).update({
          'quantity': currentQuantity + requestedQuantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: TranslatableText("Request added: Stock updated successfully!")),
        );
      } else {
        // If item does not exist, create a new entry
        await inventoryCollection.add({
          'name': itemName,
          'quantity': requestedQuantity,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: TranslatableText("New inventory item requested successfully!")),
        );
      }

      // Clear the input fields
      _nameController.clear();
      _quantityController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: TranslatableText("Error requesting item: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const TranslatableText("Request Supplies")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Item Name"),
            ),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: "Quantity"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: requestItem,
              child: const TranslatableText("Request Item"),
            ),
          ],
        ),
      ),
    );
  }
}
