import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dice Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/single_player');
              },
              child: Text('Play as Single Player'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/play_with_ai');
              },
              child: Text('Play with AI'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/multiplayer');
              },
              child: Text('Play Multiplayer'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
