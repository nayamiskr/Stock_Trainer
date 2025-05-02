import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class stock {
  final String code;
  final int userId;
  final double price;
  final int volume;

  stock({
    required this.code,
    required this.userId,
    required this.price,
    required this.volume,
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
        'volume': stock.volume,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}