import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import for FCM
import 'dart:math';
import '../widgets/dice_widget.dart';

class MultiplayerGameScreen extends StatefulWidget {
  @override
  _MultiplayerGameScreenState createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance; // For FCM

  String _currentUserId = '';
  String _currentUserName = '';
  int _diceValue = 1;
  int _currentTurnScore = 0;
  Map<String, dynamic> _scores = {};
  List<Map<String, String>> _players = []; // List of players with name and ID
  bool _isMyTurn = false;
  String _currentPlayer = '';

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _listenForGameUpdates();
    _createGameRoomIfNotExists();
    _getLoggedInPlayers();  // Fetch the logged-in players from the 'gameRoom'
    _setupFCM();  // Setup Firebase Messaging for notifications
  }
  void _createGameRoomIfNotExists() async {
    final gameRef = _firestore.collection('gameRoom').doc('game');

    try {
      // Check if the document exists
      DocumentSnapshot snapshot = await gameRef.get();
      if (!snapshot.exists) {
        // If it doesn't exist, create it
        await gameRef.set({
          'players': [],
          'diceValue': 1,
          'scores': {},
          'currentPlayer': '',
        });
        print("GameRoom created successfully.");
      } else {
        print("GameRoom already exists.");
      }
    } catch (e) {
      print("Error creating gameRoom: $e");
    }
  }




  // Add the current user to the Firestore game room
  void _addPlayerToGame() async {
    final gameRef = _firestore.collection('gameRoom').doc('game');

    try {
      await gameRef.update({
        'players': FieldValue.arrayUnion([{
          'name': _currentUserName,
          'id': _currentUserId,
        }])
      });
      print("Player $_currentUserName added to gameRoom");
    } catch (e) {
      print("Error adding player to gameRoom: $e");
    }
  }
  void _invitePlayer(String playerId) async {
    final gameRef = _firestore.collection('invites').doc();

    try {
      await gameRef.set({
        'senderId': _currentUserId,
        'receiverId': playerId,
        'status': 'pending',
      });

      print("Invite sent to player $playerId");

      // Send an FCM notification to the invited player
      _sendFCMInvite(playerId);
    } catch (e) {
      print("Error sending invite: $e");
    }
  }
  void _sendFCMInvite(String playerId) async {
    final playerDoc = await _firestore.collection('users').doc(playerId).get();
    final fcmToken = playerDoc.data()?['fcmToken'];

    if (fcmToken != null) {
      await _messaging.sendMessage(
        to: fcmToken,
        data: {
          'title': 'Game Invitation',
          'body': 'You have been invited to join a game!',
        },
      );
    }
  }


  // Listen for real-time game updates (players, scores, dice rolls, turns)
  void _listenForGameUpdates() {
    _firestore.collection('gameRoom').doc('game').snapshots().listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _diceValue = snapshot.data()?['diceValue'] ?? 1;
          _scores = Map<String, int>.from(snapshot.data()?['scores'] ?? {});
          _players = List<Map<String, String>>.from(snapshot.data()?['players'] ?? []);
          _currentPlayer = snapshot.data()?['currentPlayer'] ?? '';
          _isMyTurn = _currentPlayer == _currentUserName;
        });
        print("Game updates received: Players: $_players");
      } else {
        print("No gameRoom data found");
      }
    });
  }

  // Get all logged-in players from Firestore 'gameRoom' collection
  void _getLoggedInPlayers() {
    _firestore.collection('gameRoom').doc('game').snapshots().listen((snapshot) {
      List<Map<String, String>> playersList = [];
      var players = snapshot.data()?['players'] ?? [];
      players.forEach((player) {
        playersList.add({
          'name': player['name'] ?? 'Unknown Player',
          'id': player['id'] ?? '',
        });
        print("Player found: ${player['name']}");
      });
      setState(() {
        _players = playersList;
      });
    });
  }

  // Setup Firebase Cloud Messaging for notifications
  void _setupFCM() async {
    await _messaging.requestPermission();  // Request FCM permissions

    String? token = await _messaging.getToken();  // Get FCM token

    if (token != null) {
      print("FCM Token: $token");

      if (_currentUserId.isNotEmpty) {
        // Store FCM token in Firestore for this user
        _firestore.collection('users').doc(_currentUserId).update({
          'fcmToken': token,
        }).then((_) {
          print('FCM token successfully updated in Firestore.');
        }).catchError((error) {
          print('Failed to update FCM token: $error');
        });
      } else {
        print('Error: _currentUserId is empty.');
      }
    } else {
      print('Error: Failed to get FCM token.');
    }
  }
  void _initializeUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
        _currentUserName = user.displayName ?? 'Player';
      });
      _addPlayerToGame();
    } else {
      print("User not logged in or unable to fetch user.");
    }
  }
  void _rollDice() {
    if (!_isMyTurn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("It's not your turn!")),
      );
      return;
    }

    int roll = Random().nextInt(6) + 1;
    setState(() {
      _currentTurnScore += roll;
      _diceValue = roll;
    });

    // Update Firestore with new dice value and scores
    final gameRef = _firestore.collection('gameRoom').doc('game');
    gameRef.update({
      'diceValue': roll,
    });

    if (roll == 1) {
      setState(() {
        _currentTurnScore = 0; // Reset player's current score if they roll 1
      });
      _switchTurn();
    }
  }
 void _hold() {
    if (!_isMyTurn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("It's not your turn!")),
      );
      return;
    }

    setState(() {
      _scores[_currentUserName] = (_scores[_currentUserName] ?? 0) + _currentTurnScore;
      _currentTurnScore = 0;
    });

    // Update Firestore with the new scores and switch turn
    final gameRef = _firestore.collection('gameRoom').doc('game');
    gameRef.update({
      'scores': _scores,
      'currentPlayer': _getNextPlayer(),
    });

    _switchTurn();
  }
  void _switchTurn() {
    setState(() {
      _currentPlayer = _getNextPlayer();
      _isMyTurn = _currentPlayer == _currentUserName;
    });
  }
  String _getNextPlayer() {
    if (_players.isEmpty) {
      print('No players available.');
      return '';
    }

    int currentIndex = _players.indexWhere((player) => player['name'] == _currentPlayer);
    if (currentIndex == -1) {
      currentIndex = 0;   }
    int nextIndex = (currentIndex + 1) % _players.length;
    return _players[nextIndex]['name']!;
  }


  void _createGameRoom() async {
    final gameRef = _firestore.collection('gameRoom').doc('game');

    try {
      await gameRef.set({
        'players': [], // Initially empty list of players
        'currentPlayer': '', // No current player yet
        'scores': {}, // Empty scores for now
        'diceValue': 1, // Initial dice value
      });
      print("Game room created successfully");
    } catch (e) {
      print("Error creating game room: $e");
    }
  }
  void _listenForInvites() {
    _firestore.collection('invites').where('receiverId', isEqualTo: _currentUserId)
        .snapshots()
        .listen((snapshot) {
      snapshot.docs.forEach((doc) {
        var invite = doc.data();
        if (invite['status'] == 'pending') {
          _showInviteDialog(doc.id, invite['senderId']);
        }
      });
    });
  }
  void _showInviteDialog(String inviteId, String senderId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Game Invite'),
          content: Text('You have been invited by $senderId.'),
          actions: [
            TextButton(
              onPressed: () => _respondToInvite(inviteId, 'accepted'),
              child: Text('Accept'),
            ),
            TextButton(
              onPressed: () => _respondToInvite(inviteId, 'ignored'),
              child: Text('Ignore'),
            ),
          ],
        );
      },
    );
  }
  void _respondToInvite(String inviteId, String response) async {
    await _firestore.collection('invites').doc(inviteId).update({
      'status': response,
    });

    if (response == 'accepted') {
      _joinGame();
    }
  }
  void _listenForScores() {
    _firestore.collection('gameRoom').doc('game').snapshots().listen((snapshot) {
      setState(() {
        _scores = Map<String, dynamic>.from(snapshot.data()?['players'] ?? {});
      });
    });
  }
  void _joinGame() async {
    final gameRef = _firestore.collection('gameRoom').doc('game');

    try {
      // Check if player is already in the game
      final gameSnapshot = await gameRef.get();
      final gameData = gameSnapshot.data();

      if (gameData != null && gameData['players'] != null && gameData['players'].containsKey(_currentUserId)) {
        print("Player is already in the game.");
      } else {
        // Add the player to the game
        await gameRef.update({
          'players.${_currentUserId}': {
            'name': _currentUserName,
            'score': 0 // Initialize score as 0
          }
        });
        print("Player $_currentUserName added to gameRoom");
      }
    } catch (e) {
      print("Error joining game: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multiplayer Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _players.length,
                itemBuilder: (context, index) {
                  String playerName = _players[index]['name']!;
                  String playerId = _players[index]['id']!;
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(playerName),
                    trailing: ElevatedButton(
                      onPressed: () => _invitePlayer(playerId),
                      child: Text('Invite'),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Current Turn: $_currentPlayer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            DiceWidget(diceValue: _diceValue), // Display dice widget
            SizedBox(height: 20),
            Text(
              'Current Turn Score: $_currentTurnScore',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _rollDice,
                  child: Text('Roll Dice'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _hold,
                  child: Text('Hold'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
