import 'package:proyecto/domain/entities/inventory_item.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getItems(String userId);
  Future<List<InventoryItem>> getItemsByCategory(String categoryId);
  Future<InventoryItem> getItemById(String id);
  Future<InventoryItem> createItem(InventoryItem item);
  Future<InventoryItem> updateItem(InventoryItem item);
  Future<void> deleteItem(String id);
  Future<List<InventoryItem>> searchItems(String query, String userId);
  Future<List<InventoryItem>> filterItems({
    String? categoryId,
    DateTime? expirationBefore,
    DateTime? maintenanceBefore,
    String? location,
    String? userId,
  });
  Future<void> syncItems(String userId);
  Stream<List<InventoryItem>> watchItems(String userId);
  Future<String> exportToPdf(String userId);
}
