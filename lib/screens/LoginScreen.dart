import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personal_app/screens/SignUpScreen.dart';
import 'package:personal_app/screens/nav_screen.dart';
import 'package:personal_app/screens/transaction_screen.dart';  // Adjust import based on your file structure

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '1';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Navigate to TransactionScreen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
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
        title: Text('Login', style: TextStyle(fontSize: 30, color: Colors.white)), // Increased font size for app bar title
        centerTitle: true,
        backgroundColor: Colors.green.shade900,
      ),
      backgroundColor: Colors.black, // Set background color to black
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              cursorHeight: 30,
              controller: _emailController,
              style: TextStyle(fontSize: 30, color: Colors.white), // White text color for input text
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(fontSize: 30, color: Colors.white), // White label text color
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green.shade900), // Green border on focus
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green.shade900), // Green border for normal state
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(fontSize: 30, color: Colors.white), // White text color for input text
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(fontSize: 30, color: Colors.white), // White label text color
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green.shade900), // Green border on focus
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green.shade900), // Green border for normal state
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40), // Increase button height
                  backgroundColor: Colors.green.shade900, // Button background color
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 30, color: Colors.white), // White text for button
                ),
              ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 20), // Increased font size for error text
                ),
              ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Navigate to SignUpScreen when "Sign Up" is clicked
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: Text(
                'Don\'t have an account? Sign Up',
                style: TextStyle(fontSize: 20, color: Colors.white), // White text color for sign-up button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
