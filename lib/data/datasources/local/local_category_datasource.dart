import 'package:sqflite/sqflite.dart';
import 'package:proyecto/data/datasources/local/database_helper.dart';
import 'package:proyecto/domain/entities/category.dart';

class LocalCategoryDataSource {
  final DatabaseHelper dbHelper;

  LocalCategoryDataSource(this.dbHelper);

  Future<List<Category>> getCategories(String userId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableCategories,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) => Category.fromJson(maps[i]));
  }

  Future<Category?> getCategoryById(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Category.fromJson(maps.first);
  }

  Future<void> insertCategory(Category category) async {
    final db = await dbHelper.database;
    await db.insert(
      DatabaseHelper.tableCategories,
      category.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCategory(Category category) async {
    final db = await dbHelper.database;
    await db.update(
      DatabaseHelper.tableCategories,
      category.toJson(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await dbHelper.database;
    await db.delete(
      DatabaseHelper.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Category>> getUnsyncedCategories(String userId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableCategories,
      where: 'userId = ? AND isSynced = ?',
      whereArgs: [userId, 0],
    );

    return List.generate(maps.length, (i) => Category.fromJson(maps[i]));
  }

  Future<void> markAsSynced(String id) async {
    final db = await dbHelper.database;
    await db.update(
      DatabaseHelper.tableCategories,
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
