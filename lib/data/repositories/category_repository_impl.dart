import 'package:proyecto/core/network/network_info.dart';
import 'package:proyecto/domain/entities/category.dart';
import 'package:proyecto/domain/repositories/category_repository.dart';
import 'package:proyecto/data/datasources/local/local_category_datasource.dart';
import 'package:proyecto/data/datasources/remote/remote_category_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final RemoteCategoryDataSource remoteDataSource;
  final LocalCategoryDataSource localDataSource;
  final NetworkInfo networkInfo;

  CategoryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<Category>> getCategories(String userId) async {
    print('📚 Cargando categorías del usuario: $userId');
    
    // SIEMPRE cargar desde local primero (rápido)
    List<Category> localCategories = [];
    try {
      localCategories = await localDataSource.getCategories(userId);
      print('💾 Categorías locales cargadas: ${localCategories.length}');
    } catch (e) {
      print('❌ Error al cargar categorías locales: $e');
    }
    
    // Intentar sincronizar con Firebase en segundo plano (sin bloquear)
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      // No esperar, sincronizar en background
      _syncCategoriesInBackground(userId);
    } else {
      print('📵 Sin conexión, usando solo datos locales');
    }
    
    return localCategories;
  }
  
  // Método privado para sincronizar en background
  Future<void> _syncCategoriesInBackground(String userId) async {
    try {
      print('🔄 Sincronizando categorías en background...');
      final remoteCategories = await remoteDataSource.getCategories(userId).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⏱️ Timeout al sincronizar categorías');
          return <Category>[];
        },
      );
      
      if (remoteCategories.isNotEmpty) {
        print('✅ Categorías remotas obtenidas: ${remoteCategories.length}');
        for (var category in remoteCategories) {
          await localDataSource.insertCategory(category.copyWith(isSynced: true));
        }
      }
    } catch (e) {
      print('⚠️ Error al sincronizar categorías en background: $e');
    }
  }

  @override
  Future<Category> getCategoryById(String id) async {
    final isConnected = await networkInfo.isConnected;
    
    if (isConnected) {
      try {
        return await remoteDataSource.getCategoryById(id);
      } catch (e) {
        final category = await localDataSource.getCategoryById(id);
        if (category == null) rethrow;
        return category;
      }
    } else {
      final category = await localDataSource.getCategoryById(id);
      if (category == null) throw Exception('Categoría no encontrada');
      return category;
    }
  }

  @override
  Future<Category> createCategory(Category category) async {
    // 1. SIEMPRE guardar localmente primero
    try {
      print('📝 Guardando categoría localmente: ${category.name}');
      await localDataSource.insertCategory(category);
      print('✅ Categoría guardada localmente');
    } catch (e) {
      print('❌ Error al guardar categoría localmente: $e');
      rethrow;
    }
    
    // 2. Intentar sincronizar con Firebase si hay conexión
    try {
      final isConnected = await networkInfo.isConnected;
      
      if (isConnected) {
        try {
          await remoteDataSource.createCategory(category).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Timeout al conectar con Firebase');
            },
          );
          final syncedCategory = category.copyWith(isSynced: true);
          await localDataSource.updateCategory(syncedCategory);
          return syncedCategory;
        } catch (e) {
          print('⚠️ Error al guardar categoría en Firebase: $e');
          return category;
        }
      }
    } catch (e) {
      print('⚠️ Error al verificar conexión: $e');
    }
    
    return category;
  }

  @override
  Future<Category> updateCategory(Category category) async {
    final updatedCategory = category.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    
    // 1. SIEMPRE actualizar localmente primero
    try {
      print('📝 Actualizando categoría localmente: ${updatedCategory.name}');
      await localDataSource.updateCategory(updatedCategory);
      print('✅ Categoría actualizada localmente');
    } catch (e) {
      print('❌ Error al actualizar categoría localmente: $e');
      rethrow;
    }
    
    // 2. Intentar sincronizar con Firebase si hay conexión
    try {
      final isConnected = await networkInfo.isConnected;
      
      if (isConnected) {
        try {
          await remoteDataSource.updateCategory(updatedCategory).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Timeout al conectar con Firebase');
            },
          );
          final syncedCategory = updatedCategory.copyWith(isSynced: true);
          await localDataSource.updateCategory(syncedCategory);
          return syncedCategory;
        } catch (e) {
          print('⚠️ Error al actualizar categoría en Firebase: $e');
          return updatedCategory;
        }
      }
    } catch (e) {
      print('⚠️ Error al verificar conexión: $e');
    }
    
    return updatedCategory;
  }

  @override
  Future<void> deleteCategory(String id) async {
    await localDataSource.deleteCategory(id);
    
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      try {
        await remoteDataSource.deleteCategory(id);
      } catch (e) {
        // Will sync later
      }
    }
  }

  @override
  Future<void> syncCategories(String userId) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) return;

    try {
      // Get unsynced local categories
      final unsyncedCategories = await localDataSource.getUnsyncedCategories(userId);
      
      // Upload to remote
      for (var category in unsyncedCategories) {
        try {
          await remoteDataSource.createCategory(category);
          await localDataSource.markAsSynced(category.id);
        } catch (e) {
          // Continue with next category
        }
      }

      // Download from remote
      final remoteCategories = await remoteDataSource.getCategories(userId);
      for (var category in remoteCategories) {
        await localDataSource.insertCategory(category.copyWith(isSynced: true));
      }
    } catch (e) {
      // Sync will be retried later
    }
  }

  @override
  Stream<List<Category>> watchCategories(String userId) {
    return remoteDataSource.watchCategories(userId);
  }
}
