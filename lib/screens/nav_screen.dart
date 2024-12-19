import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:personal_app/screens/profile.dart';
import 'package:personal_app/screens/transaction_screen.dart';
import 'package:personal_app/serrvices/notf_service.dart';

import 'financial_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  NotificationService notificationService = NotificationService();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationService.requestNotificationPermission();
  }

  final List<Widget> _screens = [
    TransactionScreen(),  // Your Transaction Screen
    ProfileScreen(),      // Your Profile Screen
    FinancialScreen(),    // Your Financial Screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: GNav(
        backgroundColor: Colors.black,
        tabMargin: EdgeInsets.symmetric(vertical: 20),
        gap: 5,
        activeColor: Colors.white,
        color: Colors.white60,
        iconSize: 30,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        onTabChange: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        tabs: [
          GButton(icon: Icons.list_alt, text: 'Transavtions', backgroundColor: Colors.purple),
          GButton(icon: Icons.person, text: 'Profile', backgroundColor: Colors.purple),
          GButton(icon: Icons.grid_view_rounded, text: 'Financials', backgroundColor: Colors.purple),
        ],
      ),
      body: _screens[_currentIndex],  // Show the screen based on selected tab
    );
  }
}
