import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:aligather/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> login(BuildContext context, String email, String password) async {
    final Uri url = Uri.parse('http://192.168.100.9:3004/auth/login');

    // Create a map containing the data you want to send as JSON
    final Map<String, dynamic> data = {
      'email': email,
      'password': password,
    };

    // Encode the map as JSON
    final String jsonData = jsonEncode(data);

    // Set the request headers
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonData,
    );

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      // Request was successful
      Navigator.pushNamed(context, '/home', arguments: {
        'token': jsonResponse['token'],
        '_id': jsonResponse['user']['_id'],
        'name': jsonResponse['user']['name'],
        'location': jsonResponse['user']['location'],
        'attends': jsonResponse['user']['attends'],
      });

      _emailController.text = '';
      _passwordController.text = '';
    } else {
      String key = response.statusCode == 400 ? 'msg' : 'error';
      // Request failed
      Fluttertoast.showToast(
          msg: '${jsonResponse[key]}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.blue,
          fontSize: 16.0
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Styled Box
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: MyColors.light,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Email'),
                          ),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                          ),
                          TextButton(
                            onPressed: () {
                              // Implement login logic here
                              final password = _passwordController.text;
                              final email = _emailController.text;

                              login(context, email, password);
                            },
                            child: const Text('Submit'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text('Register'),
                          ),
                        ],
                      ),
                    )
                  )
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
