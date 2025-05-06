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
              Padding(padding: EdgeInsets.only(top: 30)),
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
                  Icon(Icons.logout),
                ],
              ),
              SizedBox(height: 30),
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: const Offset(0, 4)
                    )
                  ]
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
                      )                      
                    ),
                    SizedBox(width: 10),
                    Image.asset('assets/img/nurse.png', width: 150, height: 150),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'What do you need?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 30),
              // Menu Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    buildMenuItem(context, Icons.assignment, "MediTory", "/meditory"),
                    buildMenuItem(context, Icons.location_on, "MediLoc", "/mediloc"),
                    buildMenuItem(context, Icons.chat_bubble_outline, "MediBot", "/medibot"),
                    buildMenuItem(context, Icons.call, "MediCall", "/medicall"),
                    buildMenuItem(context, Icons.card_giftcard, "MediHajj", "/medihajj"),
                    buildMenuItem(context, Icons.info_outline, "About", "/about"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuItem(BuildContext context, IconData icon, String label, String route) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(0, 4)
          )
        ]
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
