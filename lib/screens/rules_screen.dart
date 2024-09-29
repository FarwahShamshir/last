import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rules & Regulations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Rules of the Dice Game:\n\n'
              '1. Roll the dice and move according to the number.\n'
              '2. Each player takes turns rolling the dice.\n'
              '3. The player with the highest score wins.\n'
              '4. In multiplayer, players can see each other\'s rolls in real-time.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
