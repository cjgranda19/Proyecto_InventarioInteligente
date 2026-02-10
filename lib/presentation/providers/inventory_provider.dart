import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proyecto/domain/entities/inventory_item.dart';
import 'package:proyecto/domain/repositories/inventory_repository.dart';
import 'package:proyecto/domain/usecases/inventory_usecases.dart';
import 'package:proyecto/presentation/providers/providers.dart';

class InventoryState {
  final List<InventoryItem> items;
  final bool isLoading;
  final String? error;

  InventoryState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  InventoryState copyWith({
    List<InventoryItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return InventoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class InventoryNotifier extends StateNotifier<InventoryState> {
  final InventoryRepository repository;
  final String userId;

  InventoryNotifier(this.repository, this.userId) : super(InventoryState()) {
    loadItems();
  }

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = GetItemsUseCase(repository);
      final items = await useCase.call(userId);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createItem(InventoryItem item) async {
    try {
      print('📝 Provider: Iniciando creación de item: ${item.name}');
      final useCase = CreateItemUseCase(repository);
      final newItem = await useCase.call(item);
      print('✅ Provider: Item creado: ${newItem.name}, sincronizado: ${newItem.isSynced}');
      state = state.copyWith(items: [...state.items, newItem]);
    } catch (e, stack) {
      print('❌ Provider: Error al crear item: $e');
      print('Stack: $stack');
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateItem(InventoryItem item) async {
    try {
      final useCase = UpdateItemUseCase(repository);
      final updatedItem = await useCase.call(item);
      final updatedList = state.items
          .map((i) => i.id == updatedItem.id ? updatedItem : i)
          .toList();
      state = state.copyWith(items: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      final useCase = DeleteItemUseCase(repository);
      await useCase.call(id);
      final updatedList = state.items.where((i) => i.id != id).toList();
      state = state.copyWith(items: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> searchItems(String query) async {
    state = state.copyWith(isLoading: true);
    try {
      final useCase = SearchItemsUseCase(repository);
      final items = await useCase.call(query, userId);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String> exportToPdf() async {
    try {
      print('🎯 Provider: Llamando a ExportToPdfUseCase...');
      final useCase = ExportToPdfUseCase(repository);
      final path = await useCase.call(userId);
      print('✅ Provider: PDF generado en $path');
      return path;
    } catch (e, stack) {
      print('❌ Provider: Error en exportToPdf: $e');
      print('Stack: $stack');
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<bool> syncItems() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final useCase = SyncItemsUseCase(repository);
      await useCase.call(userId);
      await loadItems();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final inventoryProvider =
    StateNotifierProvider.family<InventoryNotifier, InventoryState, String>(
  (ref, userId) {
    return InventoryNotifier(ref.watch(inventoryRepositoryProvider), userId);
  },
);
