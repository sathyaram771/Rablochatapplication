import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send a message
  Future<void> sendMessage(
      String chatId, String senderUid, String receiverUid, String content) async {
    try {
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderUid': senderUid,
        'receiverUid': receiverUid,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Edit a message
  Future<void> editMessage(
      String chatId, String messageId, String newContent) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({'content': newContent});
    } catch (e) {
      print('Error editing message: $e');
    }
  }

  // Delete a message
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  // Retrieve chat messages in real-time
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
