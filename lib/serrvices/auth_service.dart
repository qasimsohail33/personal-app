import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore for storing user data
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personal_app/screens/LoginScreen.dart';
import 'package:personal_app/screens/nav_screen.dart';
import 'package:personal_app/screens/splashscreen.dart';
import 'package:personal_app/screens/transaction_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if user is logged in
  Widget handleAuth() {
    User? user = _auth.currentUser;
    if (user != null) {
      return MainScreen(); // Show home screen if logged in
    } else {
      return LoginScreen(); // Show login screen if not logged in
    }
  }

  // Sign up function with full name
  Future<User?> signUp(String email, String password, String fullName, double balance) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save full name to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'email': email,
        'createdAt': Timestamp.now(),
        'balance' : balance,
      });

      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Login function (example)
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Get user's full name
  Future<String?> getFullName(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc['fullName'] as String?;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Logout function (example)
  Future<void> logout() async {
    await _auth.signOut();
  }
}
