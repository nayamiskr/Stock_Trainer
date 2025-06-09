import 'package:flutter/material.dart';
import 'package:stock_game/DB/StockDb.dart';
import 'package:stock_game/DB/UserDB.dart';
import 'package:stock_game/app/page/endPage.dart';

class SummaryPage extends StatelessWidget {
  final User user;
  final double nowPrice;
  final int capital;
  const SummaryPage({super.key, required this.user, required this.nowPrice, required this.capital});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("股票倉儲"), centerTitle: true),
      body: FutureBuilder<List<Stock>>(
        future: StockDb.getAllStocks(user.id),
        //先獲取所有股票資料
        builder: (context, snapshot) {
          double profit = 0.0;
          double cost = 0.0; // ← 加上成本總和

          // 計算總成本和總利潤
          for (final stock in snapshot.data ?? []) {
            final stockCost = stock.price * stock.amount * 1000;
            final stockProfit =
                (stock.nowPrice - stock.price) * stock.amount * 1000;

            cost += stockCost;
            profit += stockProfit;
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
                  Expanded(
                    child: ListView.builder(
                      itemCount: stocks.length,
                      itemBuilder: (context, index) {
                        final stock = stocks[index];
                        return ListTile(
                          leading: Icon(Icons.trending_up),
                          title: Text("股票代碼：${stock.code}"),
                          subtitle: Text(
                            "張數：${stock.amount} | 目前單價：\$${stock.nowPrice.toStringAsFixed(2)} \n| 成本：\$${stock.price.toStringAsFixed(2)}",
                          ),
                          trailing: Text(
                            "總價：\$${(stock.amount * 1000 * stock.price).toStringAsFixed(2)}",
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        int total = capital + (await StockDb.getUserTotalPrice(user.id)).toInt();
                            profit.toInt();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => Endpage(total: total - user.balance, user: user),
                          ),
                        );
                      },
                      child: Text("結束"),
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
