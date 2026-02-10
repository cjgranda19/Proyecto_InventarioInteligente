import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:proyecto/core/constants/app_constants.dart';

class DatabaseHelper {
  static Database? _database;
  
  static const String tableUsers = 'users';
  static const String tableCategories = 'categories';
  static const String tableItems = 'items';
  static const String tableSyncLog = 'sync_log';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), AppConstants.databaseName);
    
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE $tableUsers (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        displayName TEXT,
        photoUrl TEXT,
        authProvider TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        lastLogin TEXT
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE $tableCategories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        iconName TEXT,
        colorHex TEXT,
        userId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES $tableUsers (id) ON DELETE CASCADE
      )
    ''');

    // Items table
    await db.execute('''
      CREATE TABLE $tableItems (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        categoryId TEXT NOT NULL,
        imageUrl TEXT,
        localImagePath TEXT,
        quantity INTEGER DEFAULT 1,
        location TEXT,
        latitude REAL,
        longitude REAL,
        expirationDate TEXT,
        maintenanceDate TEXT,
        barcode TEXT,
        qrCode TEXT,
        tags TEXT,
        userId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0,
        FOREIGN KEY (categoryId) REFERENCES $tableCategories (id) ON DELETE CASCADE,
        FOREIGN KEY (userId) REFERENCES $tableUsers (id) ON DELETE CASCADE
      )
    ''');

    // Sync log table
    await db.execute('''
      CREATE TABLE $tableSyncLog (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entityType TEXT NOT NULL,
        entityId TEXT NOT NULL,
        action TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_categories_userId ON $tableCategories (userId)');
    await db.execute('CREATE INDEX idx_items_userId ON $tableItems (userId)');
    await db.execute('CREATE INDEX idx_items_categoryId ON $tableItems (categoryId)');
    await db.execute('CREATE INDEX idx_sync_log_synced ON $tableSyncLog (synced)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete(tableItems);
    await db.delete(tableCategories);
    await db.delete(tableUsers);
    await db.delete(tableSyncLog);
  }
}
