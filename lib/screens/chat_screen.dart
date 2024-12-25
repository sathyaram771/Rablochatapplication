import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapplication/services/chat_service.dart';
import 'package:chatapplication/widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String receiverUid;
  final String receiverName;

  const ChatScreen({Key? key, required this.receiverUid, required this.receiverName}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser!;
    final chatId = generateChatId(currentUser.uid, widget.receiverUid);

    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _chatService.getMessages(chatId),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages yet.'));
                }
                return ListView(
                  reverse: true,
                  children: snapshot.data!.docs.map((messageDoc) {
                    var messageData = messageDoc.data() as Map<String, dynamic>;
                    bool isSentByCurrentUser =
                        messageData['senderUid'] == currentUser.uid;
                    return GestureDetector(
                      onLongPress: isSentByCurrentUser
                          ? () => _showEditDeleteOptions(
                        context,
                        chatId,
                        messageDoc.id,
                        messageData['content'],
                      )
                          : null,
                      child: ChatBubble(
                        content: messageData['content'],
                        isSentByUser: isSentByCurrentUser,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    if (_messageController.text.trim().isNotEmpty) {
                      await _chatService.sendMessage(
                        chatId,
                        currentUser.uid,
                        widget.receiverUid,
                        _messageController.text.trim(),
                      );
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String generateChatId(String uid1, String uid2) {
    // Correct implementation of generateChatId
    return uid1.compareTo(uid2) < 0 ? '${uid1}_${uid2}' : '${uid2}_${uid1}';
  }

  void _showEditDeleteOptions(
      BuildContext context, String chatId, String messageId, String content) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _editMessage(chatId, messageId, content);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () async {
                Navigator.pop(context);
                await _chatService.deleteMessage(chatId, messageId);
              },
            ),
          ],
        );
      },
    );
  }

  void _editMessage(String chatId, String messageId, String oldContent) {
    final _editController = TextEditingController(text: oldContent);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Message'),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(labelText: 'Message'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                if (_editController.text.trim().isNotEmpty) {
                  await _chatService.editMessage(
                    chatId,
                    messageId,
                    _editController.text.trim(),
                  );
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
