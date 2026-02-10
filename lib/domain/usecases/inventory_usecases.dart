import 'package:proyecto/domain/entities/inventory_item.dart';
import 'package:proyecto/domain/repositories/inventory_repository.dart';

class GetItemsUseCase {
  final InventoryRepository repository;

  GetItemsUseCase(this.repository);

  Future<List<InventoryItem>> call(String userId) async {
    return await repository.getItems(userId);
  }
}

class GetItemsByCategoryUseCase {
  final InventoryRepository repository;

  GetItemsByCategoryUseCase(this.repository);

  Future<List<InventoryItem>> call(String categoryId) async {
    return await repository.getItemsByCategory(categoryId);
  }
}

class CreateItemUseCase {
  final InventoryRepository repository;

  CreateItemUseCase(this.repository);

  Future<InventoryItem> call(InventoryItem item) async {
    if (item.name.isEmpty) {
      throw Exception('El nombre del item es requerido');
    }
    return await repository.createItem(item);
  }
}

class UpdateItemUseCase {
  final InventoryRepository repository;

  UpdateItemUseCase(this.repository);

  Future<InventoryItem> call(InventoryItem item) async {
    if (item.name.isEmpty) {
      throw Exception('El nombre del item es requerido');
    }
    return await repository.updateItem(item);
  }
}

class DeleteItemUseCase {
  final InventoryRepository repository;

  DeleteItemUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteItem(id);
  }
}

class SearchItemsUseCase {
  final InventoryRepository repository;

  SearchItemsUseCase(this.repository);

  Future<List<InventoryItem>> call(String query, String userId) async {
    return await repository.searchItems(query, userId);
  }
}

class FilterItemsUseCase {
  final InventoryRepository repository;

  FilterItemsUseCase(this.repository);

  Future<List<InventoryItem>> call({
    String? categoryId,
    DateTime? expirationBefore,
    DateTime? maintenanceBefore,
    String? location,
    String? userId,
  }) async {
    return await repository.filterItems(
      categoryId: categoryId,
      expirationBefore: expirationBefore,
      maintenanceBefore: maintenanceBefore,
      location: location,
      userId: userId,
    );
  }
}

class ExportToPdfUseCase {
  final InventoryRepository repository;

  ExportToPdfUseCase(this.repository);

  Future<String> call(String userId) async {
    return await repository.exportToPdf(userId);
  }
}

class SyncItemsUseCase {
  final InventoryRepository repository;

  SyncItemsUseCase(this.repository);

  Future<void> call(String userId) async {
    return await repository.syncItems(userId);
  }
}
