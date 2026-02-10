import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:proyecto/domain/entities/category.dart';
import 'package:proyecto/presentation/providers/auth_provider.dart';
import 'package:proyecto/presentation/providers/category_provider.dart';
import 'package:proyecto/presentation/widgets/atoms/custom_button.dart';
import 'package:proyecto/presentation/widgets/atoms/custom_textfield.dart';
import 'package:proyecto/presentation/screens/inventory/category_items_screen.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    final categoryState = ref.watch(categoryProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              ref.read(categoryProvider(user.id).notifier).syncCategories();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sincronizando categorías...')),
              );
            },
          ),
        ],
      ),
      body: categoryState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryState.categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 100,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay categorías',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Presiona + para crear una',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categoryState.categories.length,
                  itemBuilder: (context, index) {
                    final category = categoryState.categories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: category.colorHex != null
                              ? Color(int.parse(
                                  category.colorHex!.replaceFirst('#', '0xff')))
                              : Theme.of(context).primaryColor,
                          child: Icon(
                            _getIconData(category.iconName),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          category.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: category.description != null
                            ? Text(category.description!)
                            : null,
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Editar'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Eliminar'),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'delete') {
                              _showDeleteDialog(context, category.id, user.id);
                            } else if (value == 'edit') {
                              _showCategoryDialog(context, user.id, category);
                            }
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryItemsScreen(
                                category: category,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context, user.id),
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'book':
        return Icons.book;
      case 'sports':
        return Icons.sports;
      case 'kitchen':
        return Icons.kitchen;
      default:
        return Icons.category;
    }
  }

  void _showDeleteDialog(BuildContext context, String categoryId, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content:
            const Text('¿Estás seguro de que quieres eliminar esta categoría?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(categoryProvider(userId).notifier).deleteCategory(categoryId);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, String userId,
      [Category? category]) {
    final nameController =
        TextEditingController(text: category?.name ?? '');
    final descController =
        TextEditingController(text: category?.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Nueva Categoría' : 'Editar Categoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              label: 'Nombre',
              controller: nameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Descripción',
              controller: descController,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          CustomButton(
            text: 'Guardar',
            onPressed: () {
              final newCategory = Category(
                id: category?.id ?? const Uuid().v4(),
                name: nameController.text,
                description: descController.text.isEmpty
                    ? null
                    : descController.text,
                userId: userId,
                createdAt: category?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
                iconName: 'category',
                colorHex: '#6200EE',
              );

              if (category == null) {
                ref
                    .read(categoryProvider(userId).notifier)
                    .createCategory(newCategory);
              } else {
                ref
                    .read(categoryProvider(userId).notifier)
                    .updateCategory(newCategory);
              }

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
