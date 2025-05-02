import 'package:flutter/material.dart';
import 'package:stock_game/DB/UserDB.dart';
import 'package:stock_game/app/page/homePage.dart';
import 'package:stock_game/app/components/textinput.dart';

class LoginPage extends StatelessWidget {
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  final dbFuture = Userdb.getDbConnect();

  LoginPage({super.key});

  Future<User?> Auth(String account, String password) async {
    final db = await dbFuture;
    final List<Map<String, dynamic>> userData = await db.query(
      'user',
      where: 'account = ? AND password = ?',
      whereArgs: [account, password],
    );
    if (userData.isNotEmpty) {
      final user = userData.first;
      return User(
        id: user['id'],
        name: user['name'],
        account: user['account'],
        password: user['password'],
      );
    }
    return null;
  }

  Future<void> login(BuildContext context) async {
    final user = await Auth(userController.text, passwordController.text);
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Homepage(currentUser: user)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wrong Account or Password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 200),
          //icon
          const Icon(Icons.account_circle, size: 150),
          //user name
          TextInput(
            controller: userController,
            hintText: 'Username',
            obscureText: false,
          ),
          const SizedBox(height: 15),
          //password
          TextInput(
            controller: passwordController,
            hintText: 'Password',
            obscureText: true,
          ),
          const SizedBox(height: 30),
          //sign in button
          SizedBox(
            width: 400,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    login(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(218, 3, 121, 255),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    dbFuture.then((db) => Userdb.insertUser(User(
                          id: 1,
                          name: userController.text,
                          account: userController.text,
                          password: passwordController.text)));
                    dbFuture.then((db) => Userdb.getAllUsers());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(218, 3, 121, 255),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          //register
        ],
      ),
    );
  }
}
