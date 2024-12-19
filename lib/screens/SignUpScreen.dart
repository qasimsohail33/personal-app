import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
import 'package:personal_app/screens/LoginScreen.dart'; // Adjust import based on your file structure

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _fullNameController = TextEditingController(); // Controller for full name
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create user in FirebaseAuth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Save user info in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'createdAt': Timestamp.now(),
      });

      // Navigate to LoginScreen after successful sign-up
      Navigator.pop(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign up', style: TextStyle(fontSize: 30, color: Colors.white)), // Increased font size for app bar title
        centerTitle: true,
        backgroundColor: Colors.purple.shade900,
        toolbarHeight: 100,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              cursorHeight: 30,
              controller: _fullNameController,
              style: TextStyle(fontSize: 30, color: Colors.white), // White text color for input text
              decoration: const InputDecoration(
                labelText: 'Full name',
                labelStyle: TextStyle(fontSize: 30, color: Colors.white), // White label text color
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green), // Green border on focus
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green), // Green border for normal state
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              cursorHeight: 30,
              controller: _emailController,
              style: TextStyle(fontSize: 30, color: Colors.white), // White text color for input text
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(fontSize: 30, color: Colors.white), // White label text color
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green), // Green border on focus
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green), // Green border for normal state
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(fontSize: 30, color: Colors.white), // White text color for input text
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(fontSize: 30, color: Colors.white), // White label text color
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green), // Green border on focus
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green), // Green border for normal state
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40), // Increase button height
                  backgroundColor: Colors.purple.shade900, // Button background color
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 30, color: Colors.white), // White text for button
                ),
              ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
