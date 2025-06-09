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
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
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

  static Future<void> deleteStock(String code, int amount) async {
    final db = await getDbConnect();
    final List<Map<String, dynamic>> order = await db.query(
      'stock',
      where: 'code = ?',
      whereArgs: [code],
    );

    if (order.isEmpty) {
      throw Exception('No stock found with code $code');
    }
    final int orderAmount = order.first['amount'];
    if (orderAmount < amount) {
      throw Exception('Insufficient stock amount to delete');
    }
    if (orderAmount > amount) {
      await db.update(
        'stock',
        {'amount': orderAmount - amount},
        where: 'code = ?',
        whereArgs: [code],
      );
    } else {
      await db.delete('stock', where: 'code = ?', whereArgs: [code]);
    }
  }

  static Future<int> getUserTotalPrice(int userId) async {
    final db = await getDbConnect();
    final List<Map<String, dynamic>> stocks = await db.query(
      'stock',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    double total = 0.0;
    for (var stock in stocks) {
      int amount = int.parse(stock['amount'].toString());
      double nowPrice = double.parse(stock['nowPrice'].toString());
      total += amount * nowPrice * 1000; // 假設每股價格是以千分之一計算
    }

    return total.toInt();
  }

  static Future<int> cleanData(int userId) async {
    final db = await getDbConnect();
    final List<Map<String, dynamic>> stocks = await db.query(
      'stock',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    double total = 0.0;
    for (var stock in stocks) {
      await db.delete('stock', where: 'code = ?', whereArgs: [stock['code']]);
    }

    return total.toInt();
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
