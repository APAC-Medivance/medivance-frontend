import 'package:flutter/material.dart';
import 'package:hajjhealth/view/admin/view/history.dart';
import 'package:hajjhealth/view/admin/view/home.dart';
import 'package:hajjhealth/view/admin/view/notifications.dart';
import 'package:hajjhealth/view/admin/view/profile.dart';

class NavbarRunnerApp extends StatefulWidget {
  @override
  _NavbarRunnerAppState createState() => _NavbarRunnerAppState();
}

class _NavbarRunnerAppState extends State<NavbarRunnerApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    AdminHomeScreen(),
    AdminNotificationScreen(),
    AdminHistoryScreen(),
    AdminProfileScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notification'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
