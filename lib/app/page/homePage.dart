import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as datatTimePicker;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:stock_game/DB/UserDB.dart';
import 'package:stock_game/app/page/stockGraph.dart';

String stockCode = '';
DateTime startDateTime = DateTime(2023, 1, 1);
DateTime endDateTime = DateTime(2023, 3, 1);
// await deleteDatabase(join(await getDatabasesPath(), 'stock.db'));

class Homepage extends StatefulWidget {
  const Homepage({super.key, required this.currentUser});
  final User currentUser;

  @override
  State<Homepage> createState() => _HomepageState();
}

int currentBalance = 0;

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    Userdb.getAllUsers();
    super.initState();
    _loadUserBalance();
  }

  Future<void> _loadUserBalance() async {
    final balance = widget.currentUser.balance;
    setState(() {
      currentBalance = balance;
    });
  }

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
                '你好${widget.currentUser.name}\n歡迎遊玩股票學習系統',
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
                            text: '${widget.currentUser.name}目前的資產: ',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      Text(
                        "$currentBalance ",
                        style: TextStyle(fontSize: 24, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
              //choose date
              SizedBox(
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('請選擇開始日期', style: TextStyle(fontSize: 20)),
                    //start date
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
                                  startDateTime = date;
                                });
                              },
                              currentTime: startDateTime,
                              locale: LocaleType.zh,
                            );
                          },
                          child: Text(
                            DateFormat("yyyy-MM-dd").format(startDateTime),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    Text('請選擇結束日期', style: TextStyle(fontSize: 20)),
                    //end date
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
                                  endDateTime = date;
                                });
                              },
                              currentTime: endDateTime,
                              locale: LocaleType.zh,
                            );
                          },
                          child: Text(
                            DateFormat("yyyy-MM-dd").format(endDateTime),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
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
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => Stockgraph(
                              startDT: startDateTime,
                              endDT: endDateTime,
                              user: widget.currentUser,
                            ),
                      ),
                    );
                    if (result == true) {
                      final newBalance = await Userdb.getUserBalance(
                        widget.currentUser.id,
                      );
                      setState(() {
                        currentBalance = newBalance; // 你要顯示的變數
                      });
                    }
                  },
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
