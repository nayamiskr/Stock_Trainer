import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as datatTimePicker;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:stock_game/app/page/stockGraph.dart';

int budget = 100000;
String stockCode = '';
DateTime dateTime = DateTime(2023, 1, 1);

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Stock Game')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //title
              Text(
                '歡迎遊玩股票學習系統',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              //show your budget
              SizedBox(
                height: 100,
                width: 350,
                child: Card.outlined(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text.rich(
                          TextSpan(
                            text: '你目前的資產: ',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      Text(
                        "\$1000000",
                        style: TextStyle(fontSize: 24, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
              //choose date
              SizedBox(
                height: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('請選擇日期', style: TextStyle(fontSize: 20)),
                    SizedBox(
                      height: 50,
                      width: 300,
                      child: ButtonTheme(
                        child: ElevatedButton(
                          onPressed: () {
                            datatTimePicker.DatePicker.showDatePicker(
                              context,
                              showTitleActions: true,
                              onConfirm: (date) {
                                setState(() {
                                  dateTime = date;
                                });
                              },
                              currentTime: dateTime,
                              locale: LocaleType.zh,
                            );
                          },
                          child: Text(
                            DateFormat("yyyy-MM-dd").format(dateTime),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //stock code search bar
              SizedBox(
                height: 200,
                width: 350,
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
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Stockgraph(stockCode: stockCode,)));
                        },
                        child: Text('查詢', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ],
                ),
              ),
              //start button
              SizedBox(
                height: 50,
                width: 200,
                child: ElevatedButton(

                  onPressed: () {},
                  child: Text('開始遊戲', style: TextStyle(fontSize: 20)),
                ),
              ), //startButton
            ],
          ),
        ),
      ),
    );
  }
}
