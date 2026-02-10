import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proyecto/domain/entities/category.dart';
import 'package:proyecto/domain/entities/inventory_item.dart';
import 'package:proyecto/presentation/providers/auth_provider.dart';
import 'package:proyecto/presentation/providers/inventory_provider.dart';
import 'package:proyecto/presentation/screens/inventory/add_item_screen.dart';
import 'dart:io';

class CategoryItemsScreen extends ConsumerStatefulWidget {
  final Category category;

  const CategoryItemsScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  ConsumerState<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends ConsumerState<CategoryItemsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    final inventoryState = ref.watch(inventoryProvider(user.id));
    
    // Filtrar items por categoría
    final categoryItems = inventoryState.items
        .where((item) => item.categoryId == widget.category.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              _getIconData(widget.category.iconName),
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.category.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: widget.category.colorHex != null
            ? Color(int.parse(widget.category.colorHex!.replaceFirst('#', '0xff')))
            : Theme.of(context).primaryColor,
      ),
      body: inventoryState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 100,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay items en esta categoría',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agrega items desde el inventario',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header con contador
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.category.colorHex != null
                            ? Color(int.parse(widget.category.colorHex!.replaceFirst('#', '0xff'))).withOpacity(0.1)
                            : Theme.of(context).primaryColor.withOpacity(0.1),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory_2,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${categoryItems.length} ${categoryItems.length == 1 ? "item" : "items"}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Lista de items
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: categoryItems.length,
                        itemBuilder: (context, index) {
                          final item = categoryItems[index];
                          return _buildItemCard(context, item, user.id);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildItemCard(BuildContext context, InventoryItem item, String userId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddItemScreen(
              userId: userId,
              item: item,
            ),
          ),
        );
      },
      onLongPress: () {
        _showItemOptionsDialog(context, item, userId);
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: item.localImagePath != null &&
                          File(item.localImagePath!).existsSync()
                      ? Image.file(
                          File(item.localImagePath!),
                          fit: BoxFit.cover,
                        )
                      : item.imageUrl != null
                          ? Image.network(
                              item.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholder();
                              },
                            )
                          : _buildPlaceholder(),
                ),
              ),
            ),
            // Información
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cant: ${item.quantity}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        if (!item.isSynced)
                          const Icon(
                            Icons.cloud_off,
                            size: 16,
                            color: Colors.orange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Icon(
      Icons.image_outlined,
      size: 50,
      color: Colors.grey[400],
    );
  }

  void _showItemOptionsDialog(BuildContext context, InventoryItem item, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(item.name),
          content: const Text('¿Qué deseas hacer con este item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddItemScreen(
                      userId: userId,
                      item: item,
                    ),
                  ),
                );
              },
              child: const Text('Editar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _confirmDelete(context, item.id, userId);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String itemId, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar este item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await ref.read(inventoryProvider(userId).notifier).deleteItem(itemId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item eliminado')),
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
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
}
