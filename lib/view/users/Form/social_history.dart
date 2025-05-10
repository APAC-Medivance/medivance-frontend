import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class SocialHistoryForm extends StatefulWidget {
  @override
  _SocialHistoryFormState createState() => _SocialHistoryFormState();
}

class _SocialHistoryFormState extends State<SocialHistoryForm>
    with SingleTickerProviderStateMixin {
  // Theme colors - Blue and White theme
  final Color primaryBlue = Color.fromARGB(255, 95, 175, 255);
  final Color lightBlue = Color(0xFFBBDEFB);
  final Color darkBlue = Color.fromARGB(255, 91, 153, 246);
  final Color white = Colors.white;

  // Firebase database instance with URL region Asia-Southeast1
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://hajjhealth-app-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  // Controllers
  final TextEditingController _workPlaceController = TextEditingController();
  final TextEditingController _mealsPerDayController = TextEditingController();
  final TextEditingController _sanitationStatusController =
      TextEditingController();
  final TextEditingController _ventilationStatusController =
      TextEditingController();

  // Switch values
  bool _isSmoker = false;
  bool _isAlcoholic = false;

  // Smoking details
  bool _showSmokingDetails = false;
  final TextEditingController _cigarettesPerDayController =
      TextEditingController();
  final TextEditingController _smokingYearsController = TextEditingController();

  // Alcohol details
  bool _showAlcoholDetails = false;
  final TextEditingController _drinksPerWeekController =
      TextEditingController();
  final TextEditingController _alcoholTypeController = TextEditingController();

  // Animation controller
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    print('Init called');
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _workPlaceController.dispose();
    _mealsPerDayController.dispose();
    _sanitationStatusController.dispose();
    _ventilationStatusController.dispose();
    _cigarettesPerDayController.dispose();
    _smokingYearsController.dispose();
    _drinksPerWeekController.dispose();
    _alcoholTypeController.dispose();
    super.dispose();
  }

  // Function to save data to Firebase
  Future<void> _saveDataToFirebase() async {
    try {
      final ref = _database.ref('social_history').push(); // generate auto-ID

      // Build data object carefully to avoid type issues
      Map<String, dynamic> socialHistoryData = {};

      // Lifestyle information
      socialHistoryData['workplace'] = _workPlaceController.text;
      socialHistoryData['mealsPerDay'] =
          _mealsPerDayController.text.isNotEmpty
              ? int.tryParse(_mealsPerDayController.text) ?? 0
              : 0;

      // Home environment
      socialHistoryData['sanitation'] = _sanitationStatusController.text;
      socialHistoryData['ventilation'] = _ventilationStatusController.text;

      // Smoking information
      socialHistoryData['isSmoker'] = _isSmoker;
      if (_isSmoker) {
        socialHistoryData['cigarettesPerDay'] =
            _cigarettesPerDayController.text.isNotEmpty
                ? int.tryParse(_cigarettesPerDayController.text) ?? 0
                : 0;
        socialHistoryData['yearsOfSmoking'] =
            _smokingYearsController.text.isNotEmpty
                ? int.tryParse(_smokingYearsController.text) ?? 0
                : 0;
      }

      // Alcohol information
      socialHistoryData['consumesAlcohol'] = _isAlcoholic;
      if (_isAlcoholic) {
        socialHistoryData['drinksPerWeek'] =
            _drinksPerWeekController.text.isNotEmpty
                ? int.tryParse(_drinksPerWeekController.text) ?? 0
                : 0;
        socialHistoryData['alcoholType'] = _alcoholTypeController.text;
      }

      // Add timestamp
      socialHistoryData['timestamp'] = ServerValue.timestamp;

      // Log data for debugging
      print('Data to save: $socialHistoryData');

      // Save to database
      await ref.set(socialHistoryData);
      return;
    } catch (e) {
      print('Error saving data: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          elevation: 8,
          color: white,
          shadowColor: darkBlue.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: lightBlue, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icon(Icons.people_alt, color: primaryBlue, size: 28),
                      // const SizedBox(width: 12),
                      // Text(
                      //   'Social History',
                      //   style: TextStyle(
                      //     fontSize: 22,
                      //     fontWeight: FontWeight.bold,
                      //     color: primaryBlue,
                      //     letterSpacing: 0.5,
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: lightBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Please provide information about your lifestyle and living conditions',
                      style: TextStyle(fontSize: 14, color: darkBlue),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Workplace and Meals per Day section
                  _buildSectionTitle('Lifestyle Information', Icons.work),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _workPlaceController,
                    labelText: 'Workplace or Occupation',
                    hintText: 'e.g., Office worker, Construction, Healthcare',
                    icon: Icons.business_center,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _mealsPerDayController,
                    labelText: 'Meals per Day',
                    hintText: 'e.g., 3',
                    icon: Icons.restaurant,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Smoking section
                  _buildSectionTitle('Smoking Status', Icons.smoking_rooms),
                  _buildCustomSwitchTile(
                    title: 'Do you smoke?',
                    value: _isSmoker,
                    onChanged: (value) {
                      setState(() {
                        _isSmoker = value;
                        _showSmokingDetails = value;
                      });
                    },
                  ),
                  AnimatedSize(
                    duration: Duration(milliseconds: 300),
                    child:
                        _showSmokingDetails
                            ? Padding(
                              padding: const EdgeInsets.only(
                                left: 12.0,
                                top: 12.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          controller:
                                              _cigarettesPerDayController,
                                          labelText: 'Cigarettes per Day',
                                          hintText: 'e.g., 5',
                                          icon: Icons.local_fire_department,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildTextField(
                                          controller: _smokingYearsController,
                                          labelText: 'Years of Smoking',
                                          hintText: 'e.g., 10',
                                          icon: Icons.calendar_today,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                            : SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),

                  // Alcohol section
                  _buildSectionTitle('Alcohol Consumption', Icons.local_bar),
                  _buildCustomSwitchTile(
                    title: 'Do you consume alcohol?',
                    value: _isAlcoholic,
                    onChanged: (value) {
                      setState(() {
                        _isAlcoholic = value;
                        _showAlcoholDetails = value;
                      });
                    },
                  ),
                  AnimatedSize(
                    duration: Duration(milliseconds: 300),
                    child:
                        _showAlcoholDetails
                            ? Padding(
                              padding: const EdgeInsets.only(
                                left: 12.0,
                                top: 12.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          controller: _drinksPerWeekController,
                                          labelText: 'Drinks per Week',
                                          hintText: 'e.g., 3',
                                          icon: Icons.sports_bar,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildTextField(
                                          controller: _alcoholTypeController,
                                          labelText: 'Type of Alcohol',
                                          hintText: 'e.g., Beer, Wine',
                                          icon: Icons.liquor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                            : SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),

                  // Home environment section
                  _buildSectionTitle('Home Environment', Icons.home),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _sanitationStatusController,
                    labelText: 'Sanitation Status at Home',
                    hintText: 'e.g., Good, Regular cleaning',
                    icon: Icons.cleaning_services,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _ventilationStatusController,
                    labelText: 'Ventilation Status at Home',
                    hintText: 'e.g., Well-ventilated, Windows in each room',
                    icon: Icons.air,
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.9, end: 1.0),
                    duration: Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              // Save form data to Firebase
                              await _saveDataToFirebase();

                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: white),
                                      SizedBox(width: 12),
                                      Text('Social history saved successfully'),
                                    ],
                                  ),
                                  backgroundColor: primaryBlue,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                            } catch (e) {
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.error, color: white),
                                      SizedBox(width: 12),
                                      Text(
                                        'Error saving data. Please try again.',
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: white,
                          elevation: 4,
                          shadowColor: primaryBlue.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          'Save Social History',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: primaryBlue),
        hintText: hintText,
        hintStyle: TextStyle(color: darkBlue.withOpacity(0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
        prefixIcon: Icon(icon, color: primaryBlue),
        filled: true,
        fillColor: white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightBlue),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: lightBlue, width: 1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryBlue, size: 20),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: value ? lightBlue.withOpacity(0.2) : white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: darkBlue,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: primaryBlue,
        activeTrackColor: lightBlue,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
