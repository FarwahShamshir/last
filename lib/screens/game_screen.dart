import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/dice_widget.dart';

class GameScreen extends StatefulWidget {
  final bool isMultiplayer;
  final bool playWithAI;

  GameScreen({required this.isMultiplayer, required this.playWithAI});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int diceValue = 1;
  int playerScore = 0;
  int aiScore = 0;
  bool isAIPlaying = false;

  void rollDice() {
    if (!widget.playWithAI) {
      // Single Player mode
      setState(() {
        diceValue = Random().nextInt(6) + 1;
        playerScore += diceValue;
      });
    } else {
      // Play with AI mode
      setState(() {
        diceValue = Random().nextInt(6) + 1;
        playerScore += diceValue;

        // AI Turn
        isAIPlaying = true;
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            diceValue = Random().nextInt(6) + 1;
            aiScore += diceValue;
            isAIPlaying = false;
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playWithAI ? 'Play with AI' : 'Single Player'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.playWithAI ? 'Your Score: $playerScore \nAI Score: $aiScore' : 'Your Score: $playerScore',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            DiceWidget(diceValue: diceValue),
            SizedBox(height: 20),
            isAIPlaying
                ? Column(
              children: [
                Image.asset('assets/robot.png', height: 100), // AI Representation
                Text('AI is Rolling...'),
              ],
            )
                : ElevatedButton(
              onPressed: rollDice,
              child: Text('Roll Dice'),
            ),
          ],
        ),
      ),
    );
  }
}
