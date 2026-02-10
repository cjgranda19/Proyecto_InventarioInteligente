import 'package:proyecto/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories(String userId);
  Future<Category> getCategoryById(String id);
  Future<Category> createCategory(Category category);
  Future<Category> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<void> syncCategories(String userId);
  Stream<List<Category>> watchCategories(String userId);
}
