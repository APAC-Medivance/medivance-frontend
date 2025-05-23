import 'package:flutter/material.dart';
import 'package:hajjhealth/view/users/HomeScreen.dart';
import 'package:hajjhealth/view/users/statistic.dart';
import 'package:hajjhealth/view/users/history.dart';
import 'package:hajjhealth/view/users/profile.dart';

class NavbarApp extends StatefulWidget {
  @override
  _NavbarAppState createState() => _NavbarAppState();
}

class _NavbarAppState extends State<NavbarApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    HealthMetricsScreen(),
    HistoryScreen(),
    ProfileViewPage(),
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
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Statistic'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
