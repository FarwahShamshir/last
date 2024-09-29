import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/multiplayer_game_screen.dart';
import 'screens/play_with_ai_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/rules_screen.dart';
import 'screens/single_player_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false; // State to track dark mode

  // Function to toggle the theme
  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dice Game',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(), // Apply dark or light theme
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/single_player': (context) => SinglePlayerScreen(),
        '/play_with_ai': (context) => PlayWithAIScreen(),
        '/multiplayer': (context) => MultiplayerGameScreen(),
        '/settings': (context) => SettingsScreen(
          isDarkMode: isDarkMode, // Pass current theme state
          toggleTheme: toggleTheme, // Pass the toggle function
        ),
        '/rules': (context) => RulesScreen(),
      },
    );
  }
}