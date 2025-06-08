import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Stock {
  final int? orderId;
  final String code;
  final int userId;
  final double price;
  final int amount;
  final double nowPrice;

  Stock({
    this.orderId,
    required this.code,
    required this.userId,
    required this.price,
    required this.amount,
    required this.nowPrice,
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
          'userId INTEGER, '
          'price REAL, '
          'amount INTEGER, '
          'nowPrice REAL, '
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
      'nowPrice': stock.nowPrice,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateNowPrice(
    String code,
    int userId,
    double nowPrice,
  ) async {
    final db = await getDbConnect();
    await db.update(
      'stock',
      {'nowPrice': nowPrice},
      where: 'code = ? AND userId = ?',
      whereArgs: [code, userId],
    );
  }

  static Future<void> deleteStock(int orderId) async {
    final db = await getDbConnect();
    await db.delete('stock', where: 'orderId = ?', whereArgs: [orderId]);
  }

  static Future<void> updateOrInsertStock({
    required String code,
    required int userId,
    required double price,
    required int amount,
    required double nowPrice,
  }) async {
    final db = await getDbConnect();
    final List<Map<String, dynamic>> existing = await db.query(
      'stock',
      where: 'code = ? AND userId = ?',
      whereArgs: [code, userId],
    );

    if (existing.isNotEmpty) {
      final current = existing.first;
      final int currentAmount = current['amount'];
      final double currentPrice = current['price'];
      final int orderId = current['orderId'];

      final int newAmount = currentAmount + amount;
      final double newTotalCost =
          (currentAmount * currentPrice) + (amount * price);
      final double averagePrice = newTotalCost / newAmount;

      await db.update(
        'stock',
        {'amount': newAmount, 'price': averagePrice, 'nowPrice': nowPrice},
        where: 'orderId = ?',
        whereArgs: [orderId],
      );
    } else {
      await insertStock(
        Stock(
          code: code,
          userId: userId,
          price: price,
          amount: amount,
          nowPrice: nowPrice,
        ),
      );
    }
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
            nowPrice: double.parse(stock['nowPrice'].toString()),
          ),
        )
        .toList();
  }
}
