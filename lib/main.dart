import 'package:flutter/material.dart';
import 'package:flutter_weather_app/screens/help_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      home: const HelpScreen(),
    );
  }
}
