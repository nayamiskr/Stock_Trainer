import 'package:flutter/material.dart';
import 'package:stock_game/DB/StockDb.dart';
import 'package:stock_game/DB/UserDB.dart';
import 'package:stock_game/app/page/homePage.dart';

class Endpage extends StatelessWidget {
  Endpage({super.key, required this.total, required this.user});
  final int total; // 假設這是結算頁面中記錄的金額
  final User user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("結算頁面"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "結算金額：\$${total.toString()}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await StockDb.cleanData(user.id); // 假設這是清除用戶股票資料的函數
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => Homepage(currentUser: user),
                  ),
                );
              },
              child: Text("返回主頁"),
            ),
          ],
        ),
      ),
    );
  }
}