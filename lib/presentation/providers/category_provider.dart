import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proyecto/domain/entities/category.dart';
import 'package:proyecto/domain/repositories/category_repository.dart';
import 'package:proyecto/domain/usecases/category_usecases.dart';
import 'package:proyecto/presentation/providers/providers.dart';
import 'package:proyecto/presentation/providers/auth_provider.dart';

class CategoryState {
  final List<Category> categories;
  final bool isLoading;
  final String? error;

  CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoryState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryRepository repository;
  final String userId;

  CategoryNotifier(this.repository, this.userId) : super(CategoryState()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = GetCategoriesUseCase(repository);
      final categories = await useCase.call(userId);
      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createCategory(Category category) async {
    try {
      final useCase = CreateCategoryUseCase(repository);
      final newCategory = await useCase.call(category);
      state = state.copyWith(
        categories: [...state.categories, newCategory],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      final useCase = UpdateCategoryUseCase(repository);
      final updatedCategory = await useCase.call(category);
      final updatedList = state.categories
          .map((c) => c.id == updatedCategory.id ? updatedCategory : c)
          .toList();
      state = state.copyWith(categories: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final useCase = DeleteCategoryUseCase(repository);
      await useCase.call(id);
      final updatedList = state.categories.where((c) => c.id != id).toList();
      state = state.copyWith(categories: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> syncCategories() async {
    try {
      final useCase = SyncCategoriesUseCase(repository);
      await useCase.call(userId);
      await loadCategories();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final categoryProvider =
    StateNotifierProvider.family<CategoryNotifier, CategoryState, String>(
  (ref, userId) {
    return CategoryNotifier(ref.watch(categoryRepositoryProvider), userId);
  },
);
