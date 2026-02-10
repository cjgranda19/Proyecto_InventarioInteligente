import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto/domain/entities/category.dart';

class RemoteCategoryDataSource {
  final FirebaseFirestore firestore;

  RemoteCategoryDataSource(this.firestore);

  Future<List<Category>> getCategories(String userId) async {
    final snapshot = await firestore
        .collection('categories')
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Category.fromJson(data);
    }).toList();
  }

  Future<Category> getCategoryById(String id) async {
    final doc = await firestore.collection('categories').doc(id).get();
    
    if (!doc.exists) {
      throw Exception('Categoría no encontrada');
    }

    final data = doc.data()!;
    data['id'] = doc.id;
    return Category.fromJson(data);
  }

  Future<void> createCategory(Category category) async {
    await firestore.collection('categories').doc(category.id).set(
      category.toJson()..remove('id'),
    );
  }

  Future<void> updateCategory(Category category) async {
    await firestore.collection('categories').doc(category.id).update(
      category.toJson()..remove('id'),
    );
  }

  Future<void> deleteCategory(String id) async {
    await firestore.collection('categories').doc(id).delete();
  }

  Stream<List<Category>> watchCategories(String userId) {
    return firestore
        .collection('categories')
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Category.fromJson(data);
      }).toList();
    });
  }
}
