import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'inventory_service.dart';
import 'package:gsc/app/central/common/translatable_text.dart';


final inventoryProvider = StateNotifierProvider<InventoryNotifier, List<Map<String, dynamic>>>(
      (ref) => InventoryNotifier(),
);

class InventoryNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final InventoryService _inventoryService = InventoryService();

  InventoryNotifier() : super([]) {
    loadInventory();
  }

  Future<void> loadInventory() async {
    state = await _inventoryService.fetchInventoryItems();
  }

  Future<void> addItem(Map<String, dynamic> itemData) async {
    await _inventoryService.addInventoryItem(itemData);
    loadInventory();
  }

  Future<void> updateItem(String itemId, Map<String, dynamic> updatedData) async {
    await _inventoryService.updateInventoryItem(itemId, updatedData);
    loadInventory();
  }

  Future<void> deleteItem(String itemId) async {
    await _inventoryService.deleteInventoryItem(itemId);
    loadInventory();
  }
}
