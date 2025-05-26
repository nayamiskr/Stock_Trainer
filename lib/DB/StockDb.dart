import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Stock {
  final int? orderId;
  final String code;
  final int userId;
  final double price;
  final int amount;

  Stock({
    this.orderId,
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
          'orderId INTEGER PRIMARY KEY AUTOINCREMENT, '
          'code TEXT, '
          'userId TEXT, '
          'price REAL, '
          'amount INTEGER, '
          'FOREIGN KEY(userId) REFERENCES user(id))',
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

  static Future<void> insertStock(Stock stock) async {
    final db = await getDbConnect();
    await db.insert('stock', {
      'code': stock.code,
      'userId': stock.userId,
      'price': stock.price,
      'amount': stock.amount,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Stock>> getAllStocks(int userId) async {
    final db = await getDbConnect();
    final List<Map<String, dynamic>> stocks = await db.query(
      'stock',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return stocks
        .map(
          (stock) => Stock(
            orderId: int.parse(stock['orderId'].toString()),
            code: stock['code'].toString(),
            userId: int.parse(stock['userId'].toString()),
            price: double.parse(stock['price'].toString()),
            amount: int.parse(stock['amount'].toString()),
          ),
        )
        .toList();
  }
}
