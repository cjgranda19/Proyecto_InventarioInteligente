import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proyecto/presentation/providers/auth_provider.dart';
import 'package:proyecto/presentation/providers/inventory_provider.dart';
import 'package:proyecto/presentation/providers/category_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No hay usuario autenticado')),
      );
    }
    
    final inventoryState = ref.watch(inventoryProvider(user.id));
    final categoryState = ref.watch(categoryProvider(user.id));
    
    final totalItems = inventoryState.items.length;
    final totalCategories = categoryState.categories.length;
    
    // Calcular items por vencer (próximos 30 días)
    final now = DateTime.now();
    final expiringItems = inventoryState.items.where((item) {
      if (item.expirationDate == null) return false;
      final daysUntilExpiration = item.expirationDate!.difference(now).inDays;
      return daysUntilExpiration >= 0 && daysUntilExpiration <= 30;
    }).length;
    
    // Estado de sincronización
    final syncStatus = inventoryState.items.any((item) => !item.isSynced)
        ? 'Pendiente'
        : 'Actualizada';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatCard(
            context,
            'Total de Items',
            totalItems.toString(),
            Icons.inventory_2,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            context,
            'Categorías',
            totalCategories.toString(),
            Icons.category,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            context,
            'Items por Vencer',
            expiringItems.toString(),
            Icons.warning,
            expiringItems > 0 ? Colors.orange : Colors.grey,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            context,
            'Sincronización',
            syncStatus,
            Icons.sync,
            syncStatus == 'Actualizada' ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
