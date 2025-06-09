import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:interactive_chart/interactive_chart.dart';
import 'package:stock_game/DB/StockDb.dart';
import 'package:stock_game/DB/UserDB.dart';
import 'package:stock_game/app/page/summaryPage.dart';

class Stockgraph extends StatefulWidget {
  const Stockgraph({
    super.key,
    required this.startDT,
    required this.endDT,
    required this.user,
  });

  final DateTime startDT;
  final DateTime endDT;
  final User user;

  @override
  State<Stockgraph> createState() => _StockgraphState();
}

class _StockgraphState extends State<Stockgraph> {
  List<CandleData> _candles = [];
  String stockCode = '';
  String stockName = '';
  double buyPrice = 0;
  int buyAmount = 0;
  double nowPrice = 0;
  double highPrice = 0;
  late int budget;
  late DateTime _startDateTime;
  late DateTime _endDateTime;

  @override
  void initState() {
    super.initState();
    budget = widget.user.balance;
    _startDateTime = widget.startDT.subtract(Duration(days: 30));
    _endDateTime = widget.startDT;
  }

  //取得公司名稱
  Future<void> getStockName(String code) async {
    final url = Uri.parse('https://openapi.twse.com.tw/v1/opendata/t187ap03_L');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      for (var item in data) {
        if (item['公司代號'] == code.substring(0, 4)) {
          stockName = item['公司簡稱'];
          return;
        }
      }
      stockName = stockCode.toUpperCase(); // 如果找不到，則使用輸入的股票代碼
    }
  }

  //更新股票的即時價格
  Future<void> updateStockNowPrice() async {
    final stocks = await StockDb.getAllStocks(widget.user.id);
    for (final stock in stocks) {
      final code = stock.code;
      final endTimestamp = _endDateTime.millisecondsSinceEpoch ~/ 1000;
      final startTimestamp = endTimestamp - (30 * 24 * 60 * 60); // 30天前的時間
      final url = Uri.parse(
        'https://query1.finance.yahoo.com/v8/finance/chart/$code?interval=1d&period1=$startTimestamp&period2=$endTimestamp&events=history&includeAdjustedClose=true',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['chart']['result'][0];
        final closes = result['indicators']['quote'][0]['close'];
        final closePrice = closes.last?.toDouble() ?? 0;

        print(closePrice);

        await StockDb.updateNowPrice(code, widget.user.id, closePrice);
      }
    }
  }

  //取得股票資料
  Future<void> fetchStockData(String symbol) async {
    final startTimestamp = _startDateTime.millisecondsSinceEpoch ~/ 1000;
    final endTimestamp = _endDateTime.millisecondsSinceEpoch ~/ 1000;
    final url = Uri.parse(
      'https://query1.finance.yahoo.com/v8/finance/chart/$symbol?interval=1d&period1=$startTimestamp&period2=$endTimestamp&events=history&includeAdjustedClose=true',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // 解析回傳的JSON資料
      final data = jsonDecode(response.body);
      final result = data['chart']['result'][0];
      final timestamps = result['timestamp'];
      final indicators = result['indicators']['quote'][0];

      final opens = indicators['open'];
      final highs = indicators['high'];
      final lows = indicators['low'];
      final closes = indicators['close'];
      final volumes = indicators['volume'];
      nowPrice = closes.isNotEmpty ? closes.last.toDouble() : 0;
      highPrice = highs.isNotEmpty ? highs.last.toDouble() : 0;

      List<CandleData> candles = [];
      // K線圖資料
      for (int i = 0; i < timestamps.length; i++) {
        if ([opens[i], highs[i], lows[i], closes[i], volumes[i]].contains(null))
          continue;
    
        // 蠟燭圖資料
        candles.add(
          CandleData(
            timestamp: timestamps[i] * 1000,
            open: opens[i],
            high: highs[i],
            low: lows[i],
            close: closes[i],
            volume: volumes[i].toDouble(),
          ),
        );
      }
      setState(() {
        _candles = candles;
      });
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('股票買賣'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: '已購股票',
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => SummaryPage(
                        userId: widget.user.id,
                        nowPrice: nowPrice,
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //顯示預算
            Text.rich(
              TextSpan(
                text: '餘額: ',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '${budget} ',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            //輸入股票代碼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "股票代碼",
                    ),
                    onChanged: (text) {
                      stockCode = text;
                    },
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (stockCode.isNotEmpty) {
                        await getStockName(stockCode);
                        await fetchStockData(stockCode);
                      }
                    },
                    child: Text('查詢', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ),

            //顯示股票名稱跟調整日期
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  '股票名稱: ${stockName}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                //箭頭icon 每按一下就往後一天
                IconButton(
                  icon: const Icon(Icons.arrow_forward_sharp),
                  onPressed: () async {
                    setState(() {
                      _endDateTime = _endDateTime.add(Duration(days: 1));
                      _startDateTime = _startDateTime.add(Duration(days: 1));
                    });
                    await updateStockNowPrice();
                    await fetchStockData(stockCode);
                  },
                ),
              ],
            ),
            // 顯示Ｋ線圖
            SizedBox(
              width: 400,
              height: 400,
              child: Padding(
                padding: EdgeInsets.all(20),
                child:
                    _candles.isNotEmpty
                        ? InteractiveChart(
                          key: ValueKey(_candles.length),
                          candles: _candles,
                          style: ChartStyle(
                            priceGainColor: Colors.red,
                            priceLossColor: Colors.green,
                          ),
                        )
                        : const Center(child: Text('目前沒有資料 請搜尋')),
              ),
            ),

            // 顯示買進金額和張數的輸入框
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 150,
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "金額",
                        ),
                        onChanged: (text) {
                          buyPrice = double.tryParse(text) ?? 0;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "張數",
                        ),
                        onChanged: (text) {
                          buyAmount = int.tryParse(text) ?? 0;
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 150,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () async {
                          //判斷金額跟價格的合理性
                          if (buyPrice * (buyAmount * 1000) <= widget.user.balance && 
                              buyPrice >= nowPrice && buyPrice < highPrice) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('成交！')));
                            //當成交就會新增資料庫
                            StockDb.updateOrInsertStock(
                              code: stockCode.toUpperCase(),
                              userId: widget.user.id,
                              price: buyPrice,
                              amount: buyAmount,
                              nowPrice: nowPrice,
                            ); 

                            // 更新使用者餘額
                            await Userdb.updateUserBalance(
                                widget.user.id,
                                (buyPrice * (buyAmount * 1000)).toInt(),
                                false,
                              ); 
                            
                            final newbudget = await Userdb.getUserBalance(widget.user.id);

                            setState(() {
                              // 更新用戶餘額
                              budget = newbudget;
                              print(budget);
                            });
                          } else {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('成交失敗！')));
                          }
                        },
                        child: Text(
                          '買進',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      width: 150,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          if (buyPrice * (buyAmount * 1000) <= budget &&
                              buyPrice <= nowPrice) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('成交！')));
                             // 假設有一個orderId為1的股票
                          } else {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('成交失敗！')));
                          }
                        },
                        child: Text(
                          '賣出',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
