import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up Method
  Future<bool> signUpUser(
      String name, String email, String mobile, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional user details in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'mobile': mobile,
      });

      return true;
    } catch (e) {
      print('Sign Up Error: $e');
      return false;
    }
  }

  // Login Method
  Future<bool> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print('Login Error: $e');
      return false;
    }
  }

  // Logout Method
  Future<void> logoutUser() async {
    await _auth.signOut();
  }
}
