import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) toggleTheme;

  SettingsScreen({required this.isDarkMode, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: isDarkMode,
            onChanged: toggleTheme,
          ),
          ListTile(
            title: Text('Highest Scores'),
            onTap: () {
              // Show highest scores
            },
          ),
          ListTile(
            title: Text('Rules & Regulations'),
            onTap: () {
              Navigator.pushNamed(context, '/rules');
            },
          ),
        ],
      ),
    );
  }
}
