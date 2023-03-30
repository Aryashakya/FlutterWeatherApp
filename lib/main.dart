import 'package:flutter/material.dart';
import 'package:flutter_weather_app/screens/help_screen.dart';
import 'package:flutter_weather_app/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool? firstTime;

getFirstScreen() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  firstTime = prefs.getBool("firstTime");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await getFirstScreen();
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
      home: (firstTime == null || firstTime!)
          ? const HelpScreen()
          : const HomeScreen(),
    );
  }
}
