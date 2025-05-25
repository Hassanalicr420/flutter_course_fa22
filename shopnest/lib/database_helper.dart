import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  final _secureStorage = const FlutterSecureStorage();

  // Encryption setup
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;

  DatabaseHelper._init() {
    // Initialize encryption (in a real app, store the key securely)
    final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
    _iv = encrypt.IV.fromLength(16);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shopnest_encrypted.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        userType TEXT NOT NULL,
        businessName TEXT,
        businessAddress TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        businessId INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        imageUrl TEXT,
        stock INTEGER DEFAULT 0,
        FOREIGN KEY (businessId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER NOT NULL,
        businessId INTEGER NOT NULL,
        totalAmount REAL NOT NULL,
        status TEXT NOT NULL,
        orderDate TEXT NOT NULL,
        deliveryAddress TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        FOREIGN KEY (customerId) REFERENCES users (id),
        FOREIGN KEY (businessId) REFERENCES users (id)
      )
    ''');
  }

  // Encrypt sensitive data before storage
  String _encryptData(String data) {
    return _encrypter.encrypt(data, iv: _iv).base64;
  }

  // Decrypt data when retrieving
  String _decryptData(String encryptedData) {
    return _encrypter.decrypt64(encryptedData, iv: _iv);
  }

  Future<int> registerUser(Map<String, dynamic> user) async {
    final db = await instance.database;

    // Encrypt sensitive data with null checks
    final encryptedUser = {
      'name': user['name'],
      'email': user['email'],
      'phone': _encryptData(user['phone'] ?? ''),
      'password': _encryptData(user['password']),
      'userType': user['userType'],
      if (user['businessName'] != null)
        'businessName': user['businessName'],
      if (user['businessAddress'] != null)
        'businessAddress': user['businessAddress'],
    };

    return await db.insert('users', encryptedUser);
  }

  Future<Map<String, dynamic>?> authenticateUser(String email, String password) async {
    try {
      final db = await instance.database;
      final encryptedPassword = _encryptData(password);

      final result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, encryptedPassword],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final user = result.first;

        // Decrypt with null safety checks
        return {
          'id': user['id'],
          'name': user['name'],
          'email': user['email'],
          'phone': _decryptData(user['phone']?.toString() ?? ''),
          'password': _decryptData(user['password']?.toString() ?? ''),
          'userType': user['userType'],
          'businessName': user['businessName'],
          'businessAddress': user['businessAddress'],
        };
      }
      return null;
    } catch (e) {
      print('Authentication error: $e');
      return null;
    }
  }

  Future<int> addProduct(Map<String, dynamic> product) async {
    final db = await instance.database;
    return await db.insert('products', product);
  }

  Future<List<Map<String, dynamic>>> getProducts(int businessId) async {
    final db = await instance.database;
    return await db.query(
      'products',
      where: 'businessId = ?',
      whereArgs: [businessId],
    );
  }

  Future<int> createOrder(Map<String, dynamic> order) async {
    final db = await instance.database;
    return await db.insert('orders', order);
  }

  Future<List<Map<String, dynamic>>> getCustomerOrders(int customerId) async {
    final db = await instance.database;
    return await db.query(
      'orders',
      where: 'customerId = ?',
      whereArgs: [customerId],
    );
  }

  Future<List<Map<String, dynamic>>> getBusinessOrders(int businessId) async {
    final db = await instance.database;
    return await db.query(
      'orders',
      where: 'businessId = ?',
      whereArgs: [businessId],
    );
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
  }
}