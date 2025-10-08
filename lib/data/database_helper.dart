import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../screens/price-checker.dart'; // optional, adjust if needed

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'products.db');
    print('📁 Database path: $path');

    // remove the deleteDatabase(path) if you don't want it to reset every run
    // await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        barcode TEXT,
        price REAL
      )
    ''');
    print('✅ Database created');
  }

  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    return await db.insert('products', product);
  }

  Future<void> batchInsertProducts(List<Map<String, dynamic>> products) async {
    final db = await database;
    
    // Use batch operations for much faster inserts
    final batch = db.batch();
    
    for (var product in products) {
      batch.insert(
        'products',
        product,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    // Commit all inserts at once
    await batch.commit(noResult: true);
  }

  Future<int> totalProduct() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(id) as count FROM products');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await database;
    return await db.query('products', orderBy: 'name ASC');
  }

  Future<int> updateProduct(int id, Map<String, dynamic> product) async {
    final db = await database;
    return await db.update('products', product, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final db = await database;
    return await db.query(
      'products',
      where: 'name LIKE ? OR barcode LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }

   Future<List<Product>> getProducts() async {
    final db = await database;
    final result = await db.query('products');
    return result.map((e) => Product(
      id: e['id'] as int,
      name: e['name'] as String,
      price: (e['price'] as num).toDouble(),
      barcode: e['barcode'] as String,
    )).toList();
  }

  Future<List<Product>> searchProduct(String query) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'name LIKE ? OR barcode LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((e) => Product(
      id: e['id'] as int,
      name: e['name'] as String,
      price: (e['price'] as num).toDouble(),
      barcode: e['barcode'] as String,
    )).toList();
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete('products');
  }
}
