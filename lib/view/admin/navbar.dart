import 'package:flutter/material.dart';
import 'package:hajjhealth/view/admin/history.dart';
import 'package:hajjhealth/view/admin/home.dart';
import 'package:hajjhealth/view/admin/notifications.dart';
import 'package:hajjhealth/view/admin/profile.dart';

class NavbarRunnerApp extends StatefulWidget {
  @override
  _NavbarRunnerAppState createState() => _NavbarRunnerAppState();
}

class _NavbarRunnerAppState extends State<NavbarRunnerApp> {
  int _selectedIndex = 0;

  // Contoh jumlah notifikasi (bisa diganti dengan dari backend / provider / API)
  int notificationCount = 3;

  final List<Widget> _screens = [
    AdminHomeScreen(),
    AdminNotificationScreen(),
    AdminHistoryScreen(),
    AdminProfileScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Contoh: reset notifikasi setelah buka tab notifikasi
      if (index == 1) {
        notificationCount = 0;
      }
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
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (notificationCount > 0)
                  Positioned(
                    left: 15,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                      child: Text(
                        '$notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notification',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
