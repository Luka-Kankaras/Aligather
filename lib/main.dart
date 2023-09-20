import 'package:flutter/material.dart';
import 'package:aligather/auth/register.dart';
import 'package:aligather/home/foreign_profile.dart';
import 'package:aligather/home/home.dart';

import 'auth/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/login': (context) => const LoginPage(), // The default route
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/f_profile': (context) => const ForeignProfilePage(),
        // Add more routes for other pages
      },
      initialRoute: '/login', // Specify the initial route
    );
  }
}
