import 'package:proyecto/domain/entities/category.dart';
import 'package:proyecto/domain/repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<Category>> call(String userId) async {
    return await repository.getCategories(userId);
  }
}

class CreateCategoryUseCase {
  final CategoryRepository repository;

  CreateCategoryUseCase(this.repository);

  Future<Category> call(Category category) async {
    if (category.name.isEmpty) {
      throw Exception('El nombre de la categoría es requerido');
    }
    return await repository.createCategory(category);
  }
}

class UpdateCategoryUseCase {
  final CategoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  Future<Category> call(Category category) async {
    if (category.name.isEmpty) {
      throw Exception('El nombre de la categoría es requerido');
    }
    return await repository.updateCategory(category);
  }
}

class DeleteCategoryUseCase {
  final CategoryRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteCategory(id);
  }
}

class SyncCategoriesUseCase {
  final CategoryRepository repository;

  SyncCategoriesUseCase(this.repository);

  Future<void> call(String userId) async {
    return await repository.syncCategories(userId);
  }
}
