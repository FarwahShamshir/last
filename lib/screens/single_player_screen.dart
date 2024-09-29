import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/dice_widget.dart';

class SinglePlayerScreen extends StatefulWidget {
  @override
  _SinglePlayerScreenState createState() => _SinglePlayerScreenState();
}

class _SinglePlayerScreenState extends State<SinglePlayerScreen> {
  int diceValue = 1;
  int playerScore = 0;

  void rollDice() {
    setState(() {
      diceValue = Random().nextInt(6) + 1;
      playerScore += diceValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Single Player'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Score: $playerScore',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            DiceWidget(diceValue: diceValue),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: rollDice,
              child: Text('Roll Dice'),
            ),
          ],
        ),
      ),
    );
  }
}
