import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:proyecto/data/datasources/local/database_helper.dart';
import 'package:proyecto/domain/entities/inventory_item.dart';

class LocalInventoryDataSource {
  final DatabaseHelper dbHelper;

  LocalInventoryDataSource(this.dbHelper);

  Future<List<InventoryItem>> getItems(String userId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableItems,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'updatedAt DESC',
    );

    return _parseItems(maps);
  }

  Future<List<InventoryItem>> getItemsByCategory(String categoryId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableItems,
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'name ASC',
    );

    return _parseItems(maps);
  }

  Future<InventoryItem?> getItemById(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableItems,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _parseItem(maps.first);
  }

  Future<void> insertItem(InventoryItem item) async {
    final db = await dbHelper.database;
    final data = item.toJson();
    if (data['tags'] is List) {
      data['tags'] = jsonEncode(data['tags']);
    }
    await db.insert(
      DatabaseHelper.tableItems,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateItem(InventoryItem item) async {
    final db = await dbHelper.database;
    final data = item.toJson();
    if (data['tags'] is List) {
      data['tags'] = jsonEncode(data['tags']);
    }
    await db.update(
      DatabaseHelper.tableItems,
      data,
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteItem(String id) async {
    final db = await dbHelper.database;
    await db.delete(
      DatabaseHelper.tableItems,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<InventoryItem>> searchItems(String query, String userId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableItems,
      where: 'userId = ? AND (name LIKE ? OR description LIKE ? OR location LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );

    return _parseItems(maps);
  }

  Future<List<InventoryItem>> filterItems({
    String? categoryId,
    DateTime? expirationBefore,
    DateTime? maintenanceBefore,
    String? location,
    String? userId,
  }) async {
    final db = await dbHelper.database;
    String where = '';
    List<dynamic> whereArgs = [];

    if (userId != null) {
      where = 'userId = ?';
      whereArgs.add(userId);
    }

    if (categoryId != null) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'categoryId = ?';
      whereArgs.add(categoryId);
    }

    if (expirationBefore != null) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'expirationDate <= ?';
      whereArgs.add(expirationBefore.toIso8601String());
    }

    if (maintenanceBefore != null) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'maintenanceDate <= ?';
      whereArgs.add(maintenanceBefore.toIso8601String());
    }

    if (location != null) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'location LIKE ?';
      whereArgs.add('%$location%');
    }

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableItems,
      where: where.isNotEmpty ? where : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'name ASC',
    );

    return _parseItems(maps);
  }

  Future<List<InventoryItem>> getUnsyncedItems(String userId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableItems,
      where: 'userId = ? AND isSynced = ?',
      whereArgs: [userId, 0],
    );

    return _parseItems(maps);
  }

  Future<void> markAsSynced(String id) async {
    final db = await dbHelper.database;
    await db.update(
      DatabaseHelper.tableItems,
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  List<InventoryItem> _parseItems(List<Map<String, dynamic>> maps) {
    return List.generate(maps.length, (i) => _parseItem(maps[i]));
  }

  InventoryItem _parseItem(Map<String, dynamic> map) {
    // Crear una copia mutable del Map (SQLite devuelve Maps inmutables)
    final mutableMap = Map<String, dynamic>.from(map);
    
    if (mutableMap['tags'] is String) {
      try {
        mutableMap['tags'] = jsonDecode(mutableMap['tags'] as String);
      } catch (e) {
        mutableMap['tags'] = [];
      }
    }
    return InventoryItem.fromJson(mutableMap);
  }
}
