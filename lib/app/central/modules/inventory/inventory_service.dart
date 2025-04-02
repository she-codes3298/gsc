import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gsc/app/central/common/translatable_text.dart';


class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchInventoryItems() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('inventory').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error fetching inventory: $e");
      return [];
    }
  }

  Future<void> addInventoryItem(Map<String, dynamic> itemData) async {
    try {
      await _firestore.collection('inventory').add(itemData);
    } catch (e) {
      print("Error adding inventory item: $e");
    }
  }

  Future<void> updateInventoryItem(String itemId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('inventory').doc(itemId).update(updatedData);
    } catch (e) {
      print("Error updating inventory item: $e");
    }
  }

  Future<void> deleteInventoryItem(String itemId) async {
    try {
      await _firestore.collection('inventory').doc(itemId).delete();
    } catch (e) {
      print("Error deleting inventory item: $e");
    }
  }
}

