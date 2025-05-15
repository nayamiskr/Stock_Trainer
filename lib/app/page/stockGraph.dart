import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:interactive_chart/interactive_chart.dart';
import 'package:stock_game/DB/StockDb.dart';

class Stockgraph extends StatefulWidget {
  const Stockgraph({
    super.key,
    required this.startDT,
    required this.endDT,
    required this.budget,
    required this.userId,
  });

  final DateTime startDT;
  final DateTime endDT;
  final int budget;
  final int userId;

  @override
  State<Stockgraph> createState() => _StockgraphState();
}

class _StockgraphState extends State<Stockgraph> {
  List<CandleData> _candles = [];
  String stockCode = '';
  double buyPrice = 0;
  int buyAmount = 0;
  late DateTime _startDateTime;
  late DateTime _endDateTime;

  @override
  void initState() {
    super.initState();
    _startDateTime = widget.startDT.subtract(Duration(days: 30));
    _endDateTime = widget.startDT;
  }

  Future<void> fetchStockData(String symbol) async {
    final startTimestamp = _startDateTime.millisecondsSinceEpoch ~/ 1000;
    final endTimestamp = _endDateTime.millisecondsSinceEpoch ~/ 1000;
    final url = Uri.parse(
      'https://query1.finance.yahoo.com/v8/finance/chart/$symbol?interval=1d&period1=$startTimestamp&period2=$endTimestamp&events=history&includeAdjustedClose=true',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final result = data['chart']['result'][0];
      final timestamps = result['timestamp'];
      final indicators = result['indicators']['quote'][0];

      final opens = indicators['open'];
      final highs = indicators['high'];
      final lows = indicators['low'];
      final closes = indicators['close'];
      final volumes = indicators['volume'];

      List<CandleData> candles = [];
      for (int i = 0; i < timestamps.length; i++) {
        if ([opens[i], highs[i], lows[i], closes[i], volumes[i]].contains(null))
          continue;

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
                    text: '${widget.budget}',
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
                        await fetchStockData(stockCode);
                      }
                    },
                    child: Text('查詢', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ),

            //顯示股票代碼跟調整日期
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Stock Code: ${stockCode}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_sharp),
                  onPressed: () async {
                    setState(() {
                      _endDateTime = _endDateTime.add(Duration(days: 1));
                      _startDateTime = _startDateTime.add(Duration(days: 1));
                    });
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
                        : const Center(child: Text('No data available')),
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
                        onPressed: () {
                          if (buyPrice * (buyAmount * 1000) <= widget.budget) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('買進成功！')));
                            StockDb.insertStock(
                              Stock(
                                code: stockCode,
                                userId: widget.userId,
                                price: buyPrice,
                                amount: buyAmount,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('超過預算！')));
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
                          if (buyPrice * (buyAmount * 1000) <= widget.budget) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('賣出成功！')));
                            StockDb.getAllStocks(widget.userId);
                          } else {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('超過預算！')));
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
