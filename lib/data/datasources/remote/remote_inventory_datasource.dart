import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto/domain/entities/inventory_item.dart';

class RemoteInventoryDataSource {
  final FirebaseFirestore firestore;

  RemoteInventoryDataSource(this.firestore);

  Future<List<InventoryItem>> getItems(String userId) async {
    final snapshot = await firestore
        .collection('items')
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return InventoryItem.fromJson(data);
    }).toList();
  }

  Future<List<InventoryItem>> getItemsByCategory(String categoryId) async {
    final snapshot = await firestore
        .collection('items')
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('name')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return InventoryItem.fromJson(data);
    }).toList();
  }

  Future<InventoryItem> getItemById(String id) async {
    final doc = await firestore.collection('items').doc(id).get();
    
    if (!doc.exists) {
      throw Exception('Item no encontrado');
    }

    final data = doc.data()!;
    data['id'] = doc.id;
    return InventoryItem.fromJson(data);
  }

  Future<void> createItem(InventoryItem item) async {
    try {
      print('📦 Preparando item para Firebase: ${item.name}');
      final itemData = item.toJson()..remove('id');
      print('📝 Datos a enviar: $itemData');
      
      await firestore.collection('items').doc(item.id).set(itemData);
      print('✅ Item guardado en Firestore con ID: ${item.id}');
    } catch (e, stack) {
      print('❌ Error al guardar en Firestore: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<void> updateItem(InventoryItem item) async {
    try {
      print('📦 Preparando item para Firebase: ${item.name}');
      final itemData = item.toJson()..remove('id');
      print('📝 Datos a enviar: $itemData');
      
      await firestore.collection('items').doc(item.id).set(itemData);
      print('✅ Item guardado en Firestore con ID: ${item.id}');
    } catch (e, stack) {
      print('❌ Error al guardar en Firestore: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    await firestore.collection('items').doc(id).delete();
  }

  Stream<List<InventoryItem>> watchItems(String userId) {
    return firestore
        .collection('items')
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return InventoryItem.fromJson(data);
      }).toList();
    });
  }
}
