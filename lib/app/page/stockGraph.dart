import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:interactive_chart/interactive_chart.dart';

class Stockgraph extends StatefulWidget {
  const Stockgraph({super.key, required this.startDT, required this.endDT, required this.budget});

  final DateTime startDT;
  final DateTime endDT;
  final int budget;
   
  @override
  State<Stockgraph> createState() => _StockgraphState();
}

class _StockgraphState extends State<Stockgraph> {
  List<CandleData> _candles = [];
  String stockCode = '';
  double buyPrice = 0;
  int buyAmount = 0;
  late DateTime _endDateTime;

  @override
  void initState() {
    super.initState();
    _endDateTime = widget.endDT;
  }

  Future<void> fetchStockData(String symbol) async {
    final startTimestamp = widget.startDT.millisecondsSinceEpoch ~/ 1000;
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '請輸入股票代碼',
                    ),
                    onChanged: (text) {
                      stockCode = text;
                    },
                  ),
                  SizedBox(
                    height: 50,
                    width: 200,
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
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Stock Code: ${stockCode}',
                  style: const TextStyle(fontSize: 24),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_sharp),
                  onPressed: () async {
                    setState(() {
                      _endDateTime = _endDateTime.add(Duration(days: 1));
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
                child: _candles.isNotEmpty
                    ? InteractiveChart(key: ValueKey(_candles.length), candles: _candles)
                    : const Center(child: Text('No data available')),
              ),
            ),
            // 顯示買進金額和張數的輸入框
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 150,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "買進金額",
                    ),
                    onChanged: (text) {
                        buyPrice = double.tryParse(text) ?? 0;
                        if (buyPrice * buyAmount > widget.budget) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('超過預算！'),
                            ),
                          );
                        }
                      },
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "買進張數",
                    ),
                    onChanged: (text) {
                        buyAmount = int.tryParse(text) ?? 0;
                        if (buyPrice * buyAmount > widget.budget) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('超過預算！'),
                            ),
                          );
                        }
                      },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
