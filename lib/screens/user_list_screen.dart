import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/chat_screen.dart';
import 'package:chatapplication/screens/login_screen.dart';

class UserListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users'),
          backgroundColor: Colors.teal,
      leading: TextButton(
    onPressed: (){
        Navigator.pushReplacement(
          context,MaterialPageRoute(builder: (context)=>LoginScreen())
        );
    },
        child: Text("Logout"),
      ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found'));
          }
          return ListView(
            children: snapshot.data!.docs.map((userDoc) {
              var userData = userDoc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(userData['name']),
                subtitle: Text(userData['email']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        receiverUid: userDoc.id,
                        receiverName: userData['name'],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
