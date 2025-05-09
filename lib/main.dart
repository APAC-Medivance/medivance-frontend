import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hajjhealth/view/admin/home/meditory.dart';
import 'package:hajjhealth/view/admin/navbar.dart';
import 'firebase_options.dart';
import 'package:hajjhealth/view/users/navbar_app.dart';
import 'package:hajjhealth/view/auth/signup.dart';
import 'package:hajjhealth/view/auth/login.dart';
import 'package:hajjhealth/view/splash/screen.dart';
import 'package:hajjhealth/view/users/Home/meditory.dart';
import 'package:hajjhealth/view/users/Home/mediloc.dart';
import 'package:hajjhealth/view/users/Home/medibot.dart';
import 'package:hajjhealth/view/users/Home/medical.dart';
import 'package:hajjhealth/view/users/Home/medihajj.dart';
import 'package:hajjhealth/view/users/Home/medinfo.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MedivanceApp());
}

class MedivanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFEAF7F9),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => NavbarApp(),
        '/meditory': (context) => MediToryScreen(),
        '/mediloc': (context) => MediLocScreen(),
        '/medibot': (context) => MediBotScreen(),
        '/medicall': (context) => MediCallScreen(),
        '/medihajj': (context) => MediHajjScreen(),
        '/about': (context) => AboutScreen(),
        '/admin/home': (context) => NavbarRunnerApp(),
        '/admin/meditory': (context) => AdminMediToryScreen()
      },
    );
  }
}