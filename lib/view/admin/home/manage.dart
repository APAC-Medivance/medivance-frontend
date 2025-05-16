import 'package:flutter/material.dart';
import 'package:hajjhealth/view/users/Form/form_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MediTory'),
        backgroundColor: Colors.blue,
      ),
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner with doctor illustration
                  _buildBanner(context),
        
                  const SizedBox(height: 20),
        
                  // Medical History Title
                  Text(
                    'Medical History',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        
                  const SizedBox(height: 8),
        
                  // Past History Card
                  _buildHistoryCard(
                    context,
                    'Past History',
                    'Contains information about your previous medical conditions, surgeries, and treatments.',
                    () => _navigateToForm(context, 'Past History'),
                  ),
        
                  const SizedBox(height: 8),
        
                  // Family History Card
                  _buildHistoryCard(
                    context,
                    'Family History',
                    'Information about medical conditions that run in your family.',
                    () => _navigateToForm(context, 'Family History'),
                  ),
        
                  const SizedBox(height: 8),
        
                  // Social History Card
                  _buildHistoryCard(
                    context,
                    'Social History',
                    'Information about your lifestyle, habits, and social factors that may affect your health.',
                    () => _navigateToForm(context, 'Social History'),
                  ),
                ],
              ),
            ),
          ),
        ),
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


