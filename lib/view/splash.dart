import 'package:flutter/material.dart';
import 'package:hajjhealth/view/HomeScreen.dart';
import 'package:hajjhealth/view/login.dart';
import 'package:hajjhealth/view/navbar_app.dart';
import 'package:hajjhealth/view/signup.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavbarApp()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/img/logo.png', height: 350),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
