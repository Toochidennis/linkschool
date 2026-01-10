import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'linkschool.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_data(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');
  }

  Future<void> saveUserData(String data) async {
    final db = await database;
    await db.insert('user_data', {'data': data});
  }

  Future<String?> getUserData() async {
    final db = await database;
    final result = await db.query('user_data', limit: 1);

    if (result.isNotEmpty) {
      return result.first['data'] as String?;
    }
    return null;
  }

  Future<void> clearUserData() async {
    final db = await database;
    await db.delete('user_data');
  }
}
