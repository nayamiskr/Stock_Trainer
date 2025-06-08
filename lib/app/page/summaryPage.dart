import 'package:flutter/material.dart';
import 'package:stock_game/DB/StockDb.dart';

class SummaryPage extends StatelessWidget {
  final int userId;
  final double nowPrice;
  const SummaryPage({super.key, required this.userId, required this.nowPrice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("股票倉儲"), centerTitle: true),
      body: FutureBuilder<List<Stock>>(
        future: StockDb.getAllStocks(userId),
        builder: (context, snapshot) {
          double profit = 0.0;
          double cost = 0.0; // ← 加上成本總和

          for (final stock in snapshot.data ?? []) {
            final stockCost = stock.price * stock.amount * 1000;
            final stockProfit =
                (stock.nowPrice - stock.price) * stock.amount * 1000;

            cost += stockCost;
            profit += stockProfit;
            print(
                "股票代碼：${stock.code}, 張數：${stock.amount}, 成本：$stockCost, 利潤：$stockProfit");
          }

          double ROI = cost == 0 ? 0 : (profit / cost) * 100;
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('目前你還沒買股票喔！', style: TextStyle(fontSize: 20)),
            );
          } else {
            final stocks = snapshot.data!;
            return Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: "報酬率 ",
                            style: TextStyle(fontSize: 18, color: Colors.black),
                            children: [
                              TextSpan(
                                text: "${ROI.toStringAsFixed(2)} %",
                                style: TextStyle(
                                  color: ROI >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            text: profit >= 0 ? "你賺了 " : "你虧了 ",
                            style: TextStyle(fontSize: 18, color: Colors.black),
                            children: [
                              TextSpan(
                                text: "${profit.abs().toStringAsFixed(0)}",
                                style: TextStyle(
                                  color:
                                      profit >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                              TextSpan(text: " 元"),
                            ],
                          ),
                        ),
                      ],
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
                            "張數：${stock.amount} | 目前單價：\$${stock.nowPrice.toStringAsFixed(2)} \n| 原價：\$${stock.price.toStringAsFixed(2)}",
                          ),
                          trailing: Text(
                            "總價：\$${(stock.amount * 1000 * stock.price).toStringAsFixed(2)}",
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
