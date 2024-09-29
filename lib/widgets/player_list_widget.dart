import 'package:flutter/material.dart';

class PlayerListWidget extends StatelessWidget {
  final List<String> players;
  final String currentPlayer;

  PlayerListWidget({required this.players, required this.currentPlayer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (String player in players)
          ListTile(
            title: Text(player),
            trailing: player == currentPlayer ? Icon(Icons.arrow_forward) : null,
          ),
      ],
    );
  }
}
