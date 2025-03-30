import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:interactive_chart/interactive_chart.dart';

class Stockgraph extends StatefulWidget {
  const Stockgraph({super.key, required this.stockCode});

  final String stockCode;

  @override
  State<Stockgraph> createState() => _StockgraphState();
}

class _StockgraphState extends State<Stockgraph> {
  List<CandleData> _candles = [];

  @override
  void initState() {
    super.initState();
    fetchStockData(widget.stockCode);
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
        if ([opens[i], highs[i], lows[i], closes[i], volumes[i]].contains(null)) continue;

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
      appBar: AppBar(title: Text("股票趨勢圖 ${widget.stockCode}")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: InteractiveChart(
            candles: _candles,
          ),
        ),
      ),
    );
  }
}
