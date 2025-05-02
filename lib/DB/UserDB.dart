import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class User {
  final int id;
  final String name;
  final String account;
  final String password;

  User({
    required this.id,
    required this.name,
    required this.account,
    required this.password,
  });
}

class Userdb {
  static Database? _database;
  static Future<Database> initDB() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'user.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE user(id TEXT PRIMARY KEY, name TEXT, account TEXT, password TEXT)',
        );
      },
      version: 1,
    );
    return _database!;
  }

  static Future<Database> getDbConnect() async {
    if (_database != null) return _database!;
    return await initDB();
  }

  static Future<void> insertUser(User user) async {
    final db = await getDbConnect();
    await db.insert(
      'user',
      {
        'id': user.id,
        'name': user.name,
        'account': user.account,
        'password': user.password,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> getAllUsers() async {
    final db = await getDbConnect();
    final List<Map<String, dynamic>> users = await db.query('user');
    
    for (var user in users) {
      print('ID: ${user['id']}, Name: ${user['name']}, Account: ${user['account']}, Password: ${user['password']}');
    }
  }
}