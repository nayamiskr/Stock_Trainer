import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:interactive_chart/interactive_chart.dart';

class Stockgraph extends StatefulWidget {
  const Stockgraph({super.key});

  @override
  State<Stockgraph> createState() => _StockgraphState();
}

class _StockgraphState extends State<Stockgraph> {
  List<CandleData> _candles = [];
  String stockCode = '';

  @override
  void initState() {
    super.initState();
    fetchStockData(stockCode);
  }

  Future<void> fetchStockData(String symbol) async {
    final url = Uri.parse(
      'https://query1.finance.yahoo.com/v8/finance/chart/$symbol?interval=1d&range=3mo',
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
            Text(
              'Stock Code: ${stockCode}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 400,
              height: 400,
              child: Padding(
                padding: EdgeInsets.all(20),
                child:
                    _candles.isEmpty
                        ? const Center(child: Text('No data available'))
                        : InteractiveChart(candles: _candles),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 150,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "買入金額",
                    ),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "賣出金額",
                    ),
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
