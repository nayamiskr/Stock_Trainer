import 'package:flutter/material.dart';
import 'package:stock_game/DB/UserDB.dart';
import 'app/page/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Userdb.initDB();
  await Userdb.getAllUsers();
  print("hello");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}