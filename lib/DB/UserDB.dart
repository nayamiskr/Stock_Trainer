import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class User {
  final int id;
  final String name;
  final String account;
  final String password;
  final int balance;

  User({
    required this.id,
    required this.name,
    required this.account,
    required this.password,
    required this.balance,
  });
}

class Userdb {
  static Database? _database;
  static Future<Database> initDB() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'user.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE user(id INTEGER PRIMARY KEY , name TEXT, account TEXT, password TEXT, balance INTEGER)',
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
    await db.insert('user', {
      'id': user.id,
      'name': user.name,
      'account': user.account,
      'password': user.password,
      'balance': user.balance,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> getUserBalance(int userId) async {
    final db = await getDbConnect();
    final List<Map<String, dynamic>> userData = await db.query(
      'user',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (userData.isNotEmpty) {
      return userData.first['balance'];
    }
    return 0; // Return 0 if user not found
  }

  static Future<void> updateUserBalance(int userId, int price, bool isAdd) async {
    final db = await getDbConnect();
    final List<Map<String, dynamic>> userData = await db.query(
      'user',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (userData.isNotEmpty) {
      int currentBalance = userData.first['balance'] as int;
      int newBalance = isAdd ? currentBalance + price : currentBalance - price;

      await db.update(
        'user',
        {'balance': newBalance},
        where: 'id = ?',
        whereArgs: [userId],
      );

      print(userData.first['balance']);
    }
  }

  static Future<void> updateUser(int userId, int balance) async {
    final db = await getDbConnect();
    await db.update(
      'user',
      {
        'balance': balance,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  static Future<void> getAllUsers() async {
    final db = await getDbConnect();
    final List<Map<String, dynamic>> users = await db.query('user');

    for (var user in users) {
      print(
        'ID: ${user['id']}, Name: ${user['name']}, Account: ${user['account']}, Password: ${user['password']}, Balance: ${user['balance']}',
      );
    }
  }
}

  