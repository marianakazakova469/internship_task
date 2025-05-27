import 'package:flutter/material.dart';
import 'utils/constants.dart';
import 'screens/login_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // <-- This is required
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Login',
      debugShowCheckedModeBanner: false,
      // Change background color to black
      theme: ThemeData(scaffoldBackgroundColor: black),
      home: const LoginScreen(), 
    );
  }
}
