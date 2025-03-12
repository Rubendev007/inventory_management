import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'inventory_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventory.db');
    return _database!;
  }

  Future<Database> _initDB(String path) async {
    final dbPath = await getDatabasesPath();
    final dbLocation = join(dbPath, path);
    return await openDatabase(dbLocation, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE inventory (
        id $idType,
        name $textType,
        category $textType,
        quantity $realType,
        unit $textType,
        lowStockThreshold $realType
      )
    ''');
  }

  // Insert a new inventory item
  Future<int> insertInventoryItem(InventoryItem item) async {
    final db = await instance.database;
    return await db.insert('inventory', item.toMap());
  }

  // Get all inventory items
  Future<List<InventoryItem>> getAllInventoryItems() async {
    final db = await instance.database;
    final result = await db.query('inventory');
    return result.map((map) => InventoryItem.fromMap(map)).toList();
  }

  // Update an existing inventory item
  Future<int> updateInventoryItem(InventoryItem item) async {
    final db = await instance.database;
    return await db.update(
      'inventory',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Delete an inventory item
  Future<int> deleteInventoryItem(int id) async {
    final db = await instance.database;
    return await db.delete(
      'inventory',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
