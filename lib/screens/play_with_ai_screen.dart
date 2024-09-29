import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/dice_widget.dart'; // Ensure you have this widget for displaying dice

class PlayWithAIScreen extends StatefulWidget {
  @override
  _PlayWithAIScreenState createState() => _PlayWithAIScreenState();
}

class _PlayWithAIScreenState extends State<PlayWithAIScreen> {
  int _playerScore = 0;
  int _aiScore = 0;
  int _currentPlayerScore = 0;
  int _currentAIScore = 0;
  int _playerDiceValue = 1; // Player dice value
  int _aiDiceValue = 1; // AI dice value
  Random _random = Random();
  bool _playerTurn = true;

  // Player rolls the dice first
  void _rollDice() async {
    int roll = _random.nextInt(6) + 1;

    if (_playerTurn) {
      setState(() {
        _playerDiceValue = roll; // Update player dice value for UI
      });

      if (roll == 1) {
        _currentPlayerScore = 0; // Reset player score for this round
        _switchTurn();
      } else {
        setState(() {
          _currentPlayerScore += roll; // Accumulate current player score
        });
      }
    } else {
      setState(() {
        _aiDiceValue = roll; // Update AI dice value for UI
      });

      if (roll == 1) {
        _currentAIScore = 0; // Reset AI score for this round
        _switchTurn();
      } else {
        setState(() {
          _currentAIScore += roll; // Accumulate AI score
        });

        // Simulate AI thinking for 1 second before deciding
        await Future.delayed(Duration(seconds: 1));

        if (_currentAIScore >= 20 || _aiScore + _currentAIScore >= 100) {
          _aiScore += _currentAIScore; // Add AI score to total
          _currentAIScore = 0; // Reset current AI score for the round
          if (_aiScore >= 100) {
            _showWinDialog('AI');
          } else {
            _switchTurn(); // AI ends its turn after reaching 20 or above
          }
        } else {
          _rollDice(); // AI rolls again if it hasn't reached its threshold
        }
      }
    }
  }

  // Hold functionality for the player
  void _hold() {
    if (_playerTurn) {
      setState(() {
        _playerScore += _currentPlayerScore; // Add current player score to total
        _currentPlayerScore = 0; // Reset current score for next round
        if (_playerScore >= 100) {
          _showWinDialog('Player');
        } else {
          _switchTurn(); // Switch turns
        }
      });
    }
  }

  // Switch turns between player and AI
  void _switchTurn() {
    setState(() {
      _playerTurn = !_playerTurn; // Toggle turn
    });
    if (!_playerTurn) {
      Future.delayed(Duration(seconds: 1), _rollDice); // AI takes its turn after 1 second
    }
  }

  // Show win dialog when either player or AI reaches 100 points
  void _showWinDialog(String winner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$winner Wins!'),
        content: Text('Final Score:\nPlayer: $_playerScore\nAI: $_aiScore'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Go back to the previous screen
            },
            child: Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Play with AI'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Player's score and icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 40, color: _playerTurn ? Colors.blue : Colors.grey),
                SizedBox(width: 10),
                Text(
                  'Player Score: $_playerScore',
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
            SizedBox(height: 10),
            // AI's score and icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.smart_toy, size: 40, color: !_playerTurn ? Colors.blue : Colors.grey),
                SizedBox(width: 10),
                Text(
                  'AI Score: $_aiScore',
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Current turn indicator
            Text(
              _playerTurn ? 'Your Turn' : 'AI\'s Turn',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            // Dice widgets for player and AI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('Player Dice', style: TextStyle(fontSize: 18)),
                    DiceWidget(diceValue: _playerDiceValue),
                  ],
                ),
                Column(
                  children: [
                    Text('AI Dice', style: TextStyle(fontSize: 18)),
                    DiceWidget(diceValue: _aiDiceValue),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            // Player controls (only shown if it's player's turn)
            if (_playerTurn)
              ElevatedButton(
                onPressed: _rollDice,
                child: Text('Roll Dice'),
              ),
            if (_playerTurn)
              SizedBox(height: 10),
            if (_playerTurn)
              ElevatedButton(
                onPressed: _hold,
                child: Text('Hold'),
              ),
          ],
        ),
      ),
    );
  }
}
