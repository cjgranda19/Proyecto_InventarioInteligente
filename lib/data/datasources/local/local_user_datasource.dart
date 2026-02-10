import 'package:sqflite/sqflite.dart';
import 'package:proyecto/data/datasources/local/database_helper.dart';
import 'package:proyecto/domain/entities/user.dart';

class LocalUserDataSource {
  final DatabaseHelper dbHelper;

  LocalUserDataSource(this.dbHelper);

  Future<void> saveUser(User user) async {
    print('💾 Guardando usuario en SQLite:');
    print('   - Email: ${user.email}');
    print('   - ID: ${user.id}');
    print('   - Provider: ${user.authProvider}');
    
    final db = await dbHelper.database;
    final userData = user.toJson();
    print('   - Datos: $userData');
    
    await db.insert(
      DatabaseHelper.tableUsers,
      userData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    print('✅ Usuario guardado exitosamente en SQLite');
  }

  Future<User?> getUser(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableUsers,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return User.fromJson(maps.first);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableUsers,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;
    return User.fromJson(maps.first);
  }

  Future<void> deleteUser(String id) async {
    final db = await dbHelper.database;
    await db.delete(
      DatabaseHelper.tableUsers,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateLastLogin(String id, DateTime lastLogin) async {
    final db = await dbHelper.database;
    await db.update(
      DatabaseHelper.tableUsers,
      {'lastLogin': lastLogin.toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Obtener el último usuario que hizo login (para mantener sesión offline)
  Future<User?> getLastLoggedInUser() async {
    print('🔍 Buscando último usuario logueado en SQLite...');
    
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableUsers,
      orderBy: 'lastLogin DESC',
      limit: 1,
    );

    print('📊 Resultados de query: ${maps.length} usuarios encontrados');
    
    if (maps.isEmpty) {
      print('❌ No hay usuarios en la base de datos local');
      return null;
    }
    
    print('✅ Usuario encontrado:');
    print('   - Datos: ${maps.first}');
    
    try {
      final user = User.fromJson(maps.first);
      print('✅ Usuario parseado correctamente: ${user.email}');
      return user;
    } catch (e) {
      print('❌ Error al parsear usuario: $e');
      return null;
    }
  }

  // Limpiar todos los usuarios (para logout completo)
  Future<void> clearAllUsers() async {
    final db = await dbHelper.database;
    await db.delete(DatabaseHelper.tableUsers);
  }
}
