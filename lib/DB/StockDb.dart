import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class stock {
  final String code;
  final int userId;
  final double price;
  final int amount;

  stock({
    required this.code,
    required this.userId,
    required this.price,
    required this.amount,
  });
}

class StockDb {
  static Database? _database;

  static Future<Database> initDB() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'stock.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE stock('
          'code TEXT, '
          'userId TEXT, '
          'price REAL, '
          'volume INTEGER, '
          'FOREIGN KEY(userId) REFERENCES user(id))'
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

  static Future<void> insertStock(stock stock) async {
    final db = await getDbConnect();
    await db.insert(
      'stock',
      {
        'code': stock.code,
        'userId': stock.userId,
        'price': stock.price,
        'amount': stock.amount,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<stock>> getAllStocks(int userId) async {
    final db = await getDbConnect();
    final List<Map<String, dynamic>> stocks = await db.query(
      'stock',
      where: 'userId = ?',
      whereArgs: [userId], 
    );

    return stocks.map((e) => stock(
    code: e['code'],
    userId: int.parse(e['userId']),
    price: e['price'],
    amount: e['amount'],
  )).toList();// Replace with the actual userId);
  }
}