import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> register(BuildContext context, String name, String location, String email, String password) async {
    final Uri url = Uri.parse('http://192.168.100.9:3004/auth/register');

    // Create a map containing the data you want to send as JSON
    final Map<String, dynamic> data = {
      'name': name,
      'location': location,
      'email': email,
      'password': password,
    };

    // Encode the map as JSON
    final String jsonData = jsonEncode(data);

    // Set the request headers
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonData,
      );

      if (response.statusCode == 201) {
        // Request was successful
        Navigator.pushNamed(context, '/login');
      } else {
        final jsonResponse = json.decode(response.body);

        Fluttertoast.showToast(
            msg: '${jsonResponse['error']}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.blue,
            fontSize: 16.0
        );
      }
    } catch (e) {
      // Handle any exceptions that may occur during the request
      Fluttertoast.showToast(
          msg: 'Error: $e',
          toastLength: Toast.LENGTH_LONG,
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
    _nameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
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
                                  controller: _nameController,
                                  decoration: const InputDecoration(labelText: 'Name'),
                                ),
                                TextFormField(
                                  controller: _locationController,
                                  decoration: const InputDecoration(labelText: 'Location'),
                                ),
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
                                    final name = _nameController.text;
                                    final location = _locationController.text;
                                    final email = _emailController.text;
                                    final password = _passwordController.text;

                                    register(context, name, location, email, password);
                                  },
                                  child: const Text('Submit'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/login');
                                  },
                                  child: const Text('Login'),
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
