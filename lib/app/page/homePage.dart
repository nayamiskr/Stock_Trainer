import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

int budget = 100000;
DateTime dateTime = DateTime(2023, 1, 1);

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Stock Game')),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  '歡迎遊玩股票學習系統',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 100,
                width: 300,
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
              SizedBox(
                height: 40,
                width: 300,
                child: ButtonTheme(child: ElevatedButton(
                  onPressed: () {
                    DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        minTime: DateTime(2023, 1, 1),
                        maxTime: DateTime(2025, 12, 31), onChanged: (date) {
                      print('change $date');
                    }, onConfirm: (date) {
                      print('confirm $date');
                      dateTime = date;
                    }, currentTime: DateTime(2023,1,1), locale: LocaleType.zh);
                  },
                  child: Text(dateTime.toString()),
                )),
              ),
              SizedBox(
                height: 50,
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/stock');
                  },
                  child: Text('開始遊戲'),
                ),  
              ) //startButton
              
            ],
          ),
        ),
      ),
    );
  }
}
