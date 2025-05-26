import 'package:flutter/material.dart';
import 'package:stock_game/DB/StockDb.dart';

class SummaryPage extends StatelessWidget {
  final int userId;
  SummaryPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("股票倉儲"), centerTitle: true),
      body: FutureBuilder<List<Stock>>(
        future: StockDb.getAllStocks(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No stocks found.'));
          } else {
            final stocks = snapshot.data!;
            return Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text("報酬率"), Text("你賺了多少")],
                    ),
                  ),
                  // Example: Display stock names
                  Expanded(
                    child: ListView.builder(
                      itemCount: stocks.length,
                      itemBuilder: (context, index) {
                        final stock = stocks[index];
                        return ListTile(
                          leading: Icon(Icons.trending_up),
                          title: Text("股票代碼：${stock.code}"),
                          subtitle: Text(
                            "張數：${stock.amount} | 單價：\$${stock.price}",
                          ),
                          trailing: Text(
                            "總價：\$${(stock.amount * stock.price).toStringAsFixed(2)}",
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
