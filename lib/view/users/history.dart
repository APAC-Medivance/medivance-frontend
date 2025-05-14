import 'package:flutter/material.dart';
import 'package:hajjhealth/view/users/Form/form_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://hajjhealth-app-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  // Color static
  final Color darkBlue = Color.fromARGB(255, 91, 153, 246);

  String medicalHistory = '';
  bool isLoading = true;
  bool hasCompleteData = false;

  @override
  void initState() {
    super.initState();
    _fetchMedicalHistory();
  }

  Future<void> _fetchMedicalHistory() async {
    try {
      final ref = _database.ref('past_history');
      final snapshot = await ref.limitToLast(1).get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        // Get the first entry (should be the most recent)
        String key = data.keys.first;
        Map<dynamic, dynamic> historyData = data[key];
        
        List<dynamic> historyItems = historyData['historyItems'] ?? [];
        
        setState(() {
          if (historyItems.isEmpty) {
            medicalHistory = 'No medical history recorded.';
          } else {
            medicalHistory = 'The patient has the following conditions: '
                '${historyItems.join(", ")}. '
                'Currently, they are taking [list medications], or '
                'say "no regular medications". There is a '
                'family history of heart disease and '
                'diabetes, but no other significant hereditary '
                'conditions. The patient is a non-smoker and '
                'does not consume alcohol. Vaccinations are '
                'up to date. Overall, there are no recent major '
                'illnesses or hospitalizations.';
          }
        });
      } else {
        setState(() {
          medicalHistory = 'No medical history recorded.';
        });
      }
    } catch (e) {
      print('Error fetching medical history: $e');
      setState(() {
        medicalHistory = 'Error loading medical history.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F9FF),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
            Color(0xFFE8F9FF),
            Colors.white
          ])
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),

            const Text("Medical History", style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black
            ),),
            
            // Medical History Card
              Card(
                color : Colors.white,
                margin: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0.4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Past History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        medicalHistory,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        )
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay health!',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Schedule an e-visit and discuss the plan with a doctor.',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFCCE7F5),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/img/nurse.png',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    String title,
    String tooltip,
    VoidCallback onTap,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 4,
      ), // Menambahkan margin horizontal
      height: 150, // Set tinggi container luar juga
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.none,
        elevation: 0.4,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.blue.withOpacity(0.1),
          highlightColor: Colors.blue.withOpacity(0.05),
          child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.9, // Lebar card
              height: 150, // Tinggi card
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 45.0,
                      ), // Mengurangi padding untuk menyesuaikan dengan tinggi card
                      child: Row(
                        children: [
                          // Icon for the card
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIconForTitle(title),
                              color: Colors.blue,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Title and subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap to view details',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Arrow indicator
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.blue.withOpacity(0.7),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Info icon with tooltip
              Positioned(
                top: 9,
                right: 11,
                child: Hero(
                  tag: 'info_$title',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _showInfoDialog(context, title, tooltip);
                      },
                      customBorder: const CircleBorder(),
                      child: Tooltip(
                        message: tooltip,
                        preferBelow: false,
                        padding: const EdgeInsets.all(12),
                        textStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Get appropriate icon based on history type
  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Past History':
        return Icons.history;
      case 'Family History':
        return Icons.family_restroom;
      case 'Social History':
        return Icons.people;
      default:
        return Icons.article;
    }
  }

  // Show info dialog when info icon is tapped
  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 0,
                  spreadRadius: 0.1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: GoogleFonts.poppins(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Got it',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToForm(BuildContext context, String formType) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormScreen(formType: formType)),
    );
  }
}


