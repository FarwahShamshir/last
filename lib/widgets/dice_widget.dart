import 'package:flutter/material.dart';

class DiceWidget extends StatelessWidget {
  final int diceValue;

  DiceWidget({required this.diceValue});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'images/dice$diceValue.jpg', // Assuming you have images named dice1.png, dice2.png, etc.
      height: 100,
      errorBuilder: (context, error, stackTrace) {
        return Text(
          'Error loading dice image',
          style: TextStyle(color: Colors.red),
        );
      },
    );
  }
}
