import 'package:cloud_firestore/cloud_firestore.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send an invitation to another player
  Future<void> sendInvitation(String senderId, String receiverId) async {
    await _firestore.collection('invitations').add({
      'sender': senderId,
      'receiver': receiverId,
      'status': 'pending', // Status is pending until accepted/declined
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Listen for invitations for the current player
  Stream<QuerySnapshot> listenForInvitations(String receiverId) {
    return _firestore
        .collection('invitations')
        .where('receiver', isEqualTo: receiverId)
        .where('status', isEqualTo: 'pending') // Only show pending invitations
        .snapshots();
  }

  // Accept an invitation
  Future<void> acceptInvitation(String invitationId) async {
    await _firestore.collection('invitations').doc(invitationId).update({
      'status': 'accepted',
    });
  }

  // Decline an invitation
  Future<void> declineInvitation(String invitationId) async {
    await _firestore.collection('invitations').doc(invitationId).update({
      'status': 'declined',
    });
  }

  // Create a new game room for the two players
  Future<void> createGameRoom(String player1, String player2) async {
    await _firestore.collection('games').add({
      'player1': player1,
      'player2': player2,
      'gameState': {
        'diceValue': 1,
        'currentPlayer': player1,  // Player 1 starts the game
        'scores': {player1: 0, player2: 0},  // Initial scores
      },
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
