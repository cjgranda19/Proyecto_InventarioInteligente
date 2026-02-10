import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:proyecto/core/network/network_info.dart';
import 'package:proyecto/domain/entities/inventory_item.dart';
import 'package:proyecto/domain/repositories/inventory_repository.dart';
import 'package:proyecto/data/datasources/local/local_inventory_datasource.dart';
import 'package:proyecto/data/datasources/local/local_category_datasource.dart';
import 'package:proyecto/data/datasources/remote/remote_inventory_datasource.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final RemoteInventoryDataSource remoteDataSource;
  final LocalInventoryDataSource localDataSource;
  final LocalCategoryDataSource localCategoryDataSource;
  final NetworkInfo networkInfo;

  InventoryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.localCategoryDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<InventoryItem>> getItems(String userId) async {
    print('📦 Cargando items del usuario: $userId');
    
    // SIEMPRE cargar desde local primero (rápido)
    List<InventoryItem> localItems = [];
    try {
      localItems = await localDataSource.getItems(userId);
      print('💾 Items locales cargados: ${localItems.length}');
    } catch (e) {
      print('❌ Error al cargar items locales: $e');
    }
    
    // Intentar sincronizar con Firebase en segundo plano (sin bloquear)
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      // No esperar, sincronizar en background
      _syncItemsInBackground(userId);
    } else {
      print('📵 Sin conexión, usando solo datos locales');
    }
    
    return localItems;
  }
  
  // Método privado para sincronizar en background
  Future<void> _syncItemsInBackground(String userId) async {
    try {
      print('🔄 Sincronizando items en background...');
      final remoteItems = await remoteDataSource.getItems(userId).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⏱️ Timeout al sincronizar items');
          return <InventoryItem>[];
        },
      );
      
      if (remoteItems.isNotEmpty) {
        print('✅ Items remotos obtenidos: ${remoteItems.length}');
        for (var item in remoteItems) {
          await localDataSource.insertItem(item.copyWith(isSynced: true));
        }
      }
    } catch (e) {
      print('⚠️ Error al sincronizar items en background: $e');
    }
  }

  @override
  Future<List<InventoryItem>> getItemsByCategory(String categoryId) async {
    return await localDataSource.getItemsByCategory(categoryId);
  }

  @override
  Future<InventoryItem> getItemById(String id) async {
    final item = await localDataSource.getItemById(id);
    if (item == null) throw Exception('Item no encontrado');
    return item;
  }

  @override
  Future<InventoryItem> createItem(InventoryItem item) async {
    // 1. SIEMPRE guardar localmente primero
    try {
      print('📝 Guardando item localmente: ${item.name}');
      await localDataSource.insertItem(item);
      print('✅ Item guardado localmente');
    } catch (e) {
      print('❌ Error al guardar localmente: $e');
      rethrow; // Si falla local, no continuar
    }
    
    // 2. Intentar sincronizar con Firebase si hay conexión
    try {
      final isConnected = await networkInfo.isConnected;
      print('🌐 Conectado a internet: $isConnected');
      
      if (isConnected) {
        try {
          print('☁️ Intentando guardar en Firebase...');
          await remoteDataSource.createItem(item).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Timeout al conectar con Firebase');
            },
          );
          print('✅ Item guardado en Firebase exitosamente');
          
          // Marcar como sincronizado
          final syncedItem = item.copyWith(isSynced: true);
          await localDataSource.updateItem(syncedItem);
          return syncedItem;
        } catch (e) {
          print('⚠️ Error al guardar en Firebase (guardado localmente): $e');
          // Retornar item no sincronizado pero guardado localmente
          return item;
        }
      } else {
        print('📵 Sin conexión, guardado solo localmente');
        return item;
      }
    } catch (e) {
      print('⚠️ Error al verificar conexión: $e');
      // Retornar item guardado localmente
      return item;
    }
  }

  @override
  Future<InventoryItem> updateItem(InventoryItem item) async {
    final updatedItem = item.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    
    // 1. SIEMPRE actualizar localmente primero
    try {
      print('📝 Actualizando item localmente: ${updatedItem.name}');
      await localDataSource.updateItem(updatedItem);
      print('✅ Item actualizado localmente');
    } catch (e) {
      print('❌ Error al actualizar localmente: $e');
      rethrow; // Si falla local, no continuar
    }
    
    // 2. Intentar sincronizar con Firebase si hay conexión
    try {
      final isConnected = await networkInfo.isConnected;
      print('🌐 Conectado a internet: $isConnected');
      
      if (isConnected) {
        try {
          print('☁️ Intentando actualizar en Firebase...');
          await remoteDataSource.updateItem(updatedItem).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Timeout al conectar con Firebase');
            },
          );
          print('✅ Item actualizado en Firebase exitosamente');
          
          // Marcar como sincronizado
          final syncedItem = updatedItem.copyWith(isSynced: true);
          await localDataSource.updateItem(syncedItem);
          return syncedItem;
        } catch (e) {
          print('⚠️ Error al actualizar en Firebase (actualizado localmente): $e');
          return updatedItem;
        }
      } else {
        print('📵 Sin conexión, actualizado solo localmente');
        return updatedItem;
      }
    } catch (e) {
      print('⚠️ Error al verificar conexión: $e');
      return updatedItem;
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    await localDataSource.deleteItem(id);
    
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      try {
        await remoteDataSource.deleteItem(id);
      } catch (e) {
        // Will sync later
      }
    }
  }

  @override
  Future<List<InventoryItem>> searchItems(String query, String userId) async {
    return await localDataSource.searchItems(query, userId);
  }

  @override
  Future<List<InventoryItem>> filterItems({
    String? categoryId,
    DateTime? expirationBefore,
    DateTime? maintenanceBefore,
    String? location,
    String? userId,
  }) async {
    return await localDataSource.filterItems(
      categoryId: categoryId,
      expirationBefore: expirationBefore,
      maintenanceBefore: maintenanceBefore,
      location: location,
      userId: userId,
    );
  }

  @override
  Future<void> syncItems(String userId) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) return;

    try {
      final unsyncedItems = await localDataSource.getUnsyncedItems(userId);
      
      for (var item in unsyncedItems) {
        try {
          await remoteDataSource.createItem(item);
          await localDataSource.markAsSynced(item.id);
        } catch (e) {
          // Continue with next item
        }
      }

      final remoteItems = await remoteDataSource.getItems(userId);
      for (var item in remoteItems) {
        await localDataSource.insertItem(item.copyWith(isSynced: true));
      }
    } catch (e) {
      // Sync will be retried later
    }
  }

  @override
  Stream<List<InventoryItem>> watchItems(String userId) {
    return remoteDataSource.watchItems(userId);
  }

  @override
  Future<String> exportToPdf(String userId) async {
    print('📊 Iniciando exportación de PDF...');
    final items = await localDataSource.getItems(userId);
    final categories = await localCategoryDataSource.getCategories(userId);
    print('📦 Items encontrados: ${items.length}');
    print('📚 Categorías encontradas: ${categories.length}');
    
    // Crear mapa de categoryId -> categoryName para fácil acceso
    final categoryMap = {for (var cat in categories) cat.id: cat.name};
    
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Inventario Completo', 
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Nombre', 'Cantidad', 'Categoría', 'Ubicación'],
            data: items.map((item) => [
              item.name,
              item.quantity.toString(),
              categoryMap[item.categoryId] ?? 'Sin categoría',
              item.location ?? 'Sin ubicación',
            ]).toList(),
          ),
        ],
      ),
    );

    try {
      // Guardar el PDF
      final pdfData = await pdf.save();
      
      Directory? directory;
      String path;
      
      if (Platform.isAndroid) {
        // Para Android 10+: usar directorio de la app (no requiere permisos especiales)
        // El PDF será accesible desde la app de archivos del dispositivo
        directory = await getExternalStorageDirectory();
        final String fileName = 'Inventario_${DateTime.now().millisecondsSinceEpoch}.pdf';
        path = '${directory!.path}/$fileName';
        
        print('💾 Guardando PDF en directorio de app: $path');
        final File file = File(path);
        await file.writeAsBytes(pdfData);
      } else {
        directory = await getApplicationDocumentsDirectory();
        final String fileName = 'Inventario_${DateTime.now().millisecondsSinceEpoch}.pdf';
        path = '${directory.path}/$fileName';
        
        final File file = File(path);
        await file.writeAsBytes(pdfData);
      }
      
      print('✅ PDF guardado exitosamente');
      print('📁 Ubicación: $path');
      return path;
    } catch (e, stack) {
      print('❌ Error al guardar PDF: $e');
      print('Stack: $stack');
      rethrow;
    }
  }
}
