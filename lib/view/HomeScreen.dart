import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final Color backgroundColor = Color(0xFFE8F9FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      "https://i.pravatar.cc/150?img=3",
                    ),
                    radius: 20,
                  ),
                  Icon(Icons.qr_code_scanner),
                ],
              ),
              SizedBox(height: 16),
              Text('Hello,', style: TextStyle(fontSize: 22)),
              Text(
                'Sarah!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Card
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stay health!',
                            style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Schedule an e-visit and discuss the plan with a doctor.',
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Image.asset('assets/img/nurse.png', width: 150, height: 150),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'What do you need?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 12),
              // Menu Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    buildMenuItem(Icons.assignment, "MediTory"),
                    buildMenuItem(Icons.location_on, "MediLoc"),
                    buildMenuItem(Icons.chat_bubble_outline, "MediBot"),
                    buildMenuItem(Icons.call, "MediCall"),
                    buildMenuItem(Icons.card_giftcard, "MediHajj"),
                    buildMenuItem(Icons.info_outline, "About"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuItem(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // TODO: add navigation
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
