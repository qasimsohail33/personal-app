import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:personal_app/screens/Gridview.dart';
import 'package:personal_app/screens/LoginScreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _fullName;
  String? _email;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  void _showEditNameDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Full Name'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Enter new full name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String newName = nameController.text;
                if (newName.isNotEmpty) {
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId != null) {
                    await FirebaseFirestore.instance.collection('users').doc(userId).update({
                      'fullName': newName,
                    });
                    setState(() {
                      _fullName = newName;
                    });
                  }
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Fetch the user's profile details (Name, Email, Profile Picture)
  Future<void> _fetchUserProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      setState(() {
        _fullName = doc['fullName'];
        _email = doc['email'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return LoginScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.account_circle, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Information Card
              Card(
                color: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // _profilePicUrl != null
                      //     ? CircleAvatar(
                      //   radius: 50,
                      //   backgroundImage: NetworkImage(_profilePicUrl!),
                      // )
                      //     : CircleAvatar(
                      //   radius: 50,
                      //   backgroundColor: Colors.grey,
                      //   child: Icon(Icons.person, color: Colors.white, size: 50),
                      // ),
                      SizedBox(height: 15),
                      Text(
                        _fullName ?? 'Loading...',
                        style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _email ?? 'Loading...',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Buttons Section
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch, // This ensures full width for buttons
                children: [
                  // Edit Full Name Button
                  ElevatedButton.icon(
                    onPressed: () => _showEditNameDialog(context),
                    icon: Icon(Icons.edit, color: Colors.white),
                    label: Text('Edit Full Name', style: TextStyle(color: Colors.white, fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple, // Background color
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      minimumSize: Size(double.infinity, 60), // Full-width and increased height
                    ),
                  ),
                  SizedBox(height: 10),

                  // Log Out Button
                  // Go to Transactions Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TransactionGridsPage()),
                      );
                    },
                    icon: Icon(Icons.credit_card, color: Colors.white),
                    label: Text('Go to Grid View', style: TextStyle(color: Colors.white, fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple, // Background color
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      minimumSize: Size(double.infinity, 60), // Full-width and increased height
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    icon: Icon(Icons.logout, color: Colors.white),
                    label: Text('Log Out', style: TextStyle(color: Colors.white, fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple, // Background color
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      minimumSize: Size(double.infinity, 60), // Full-width and increased height
                    ),
                  ),
                  SizedBox(height: 10),

                ],
              )
              ,
            ],
          ),
        ),
      ),
    );
  }
}
