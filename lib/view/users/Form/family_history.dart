import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FamilyHistoryForm extends StatefulWidget {
  @override
  _FamilyHistoryFormState createState() => _FamilyHistoryFormState();
}

class _FamilyHistoryFormState extends State<FamilyHistoryForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Firebase database instance dengan URL region Asia-Southeast1
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://hajjhealth-app-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  // Theme colors
  final Color primaryBlue = Color.fromARGB(255, 95, 175, 255);
  final Color lightBlue = Color(0xFFBBDEFB);
  final Color darkBlue = Color.fromARGB(255, 91, 153, 246);
  final Color white = Colors.white;

  bool _showMotherDetails = true;
  bool _showFatherDetails = true;
  bool _showSiblingsDetails = true;

  bool _motherHasCondition = false;
  bool _fatherHasCondition = false;
  bool _siblingsHaveCondition = false;

  // Controllers
  final _motherConditionCtrl = TextEditingController();
  final _motherYearCtrl = TextEditingController();
  final _motherMedicationCtrl = TextEditingController();

  final _fatherConditionCtrl = TextEditingController();
  final _fatherYearCtrl = TextEditingController();
  final _fatherMedicationCtrl = TextEditingController();

  final _siblingsConditionCtrl = TextEditingController();
  final _siblingsYearCtrl = TextEditingController();
  final _siblingsMedicationCtrl = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _motherConditionCtrl.dispose();
    _motherYearCtrl.dispose();
    _motherMedicationCtrl.dispose();
    _fatherConditionCtrl.dispose();
    _fatherYearCtrl.dispose();
    _fatherMedicationCtrl.dispose();
    _siblingsConditionCtrl.dispose();
    _siblingsYearCtrl.dispose();
    _siblingsMedicationCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveDataToFirebase() async {
    final ref = _database.ref('family_history').push(); // generate auto-ID
    await ref.set({
      'mother': _motherHasCondition
          ? {
              'condition': _motherConditionCtrl.text,
              'diagnosisYear': _motherYearCtrl.text,
              'medication': _motherMedicationCtrl.text,
            }
          : null,
      'father': _fatherHasCondition
          ? {
              'condition': _fatherConditionCtrl.text,
              'diagnosisYear': _fatherYearCtrl.text,
              'medication': _fatherMedicationCtrl.text,
            }
          : null,
      'siblings': _siblingsHaveCondition
          ? {
              'condition': _siblingsConditionCtrl.text,
              'diagnosisYear': _siblingsYearCtrl.text,
              'medication': _siblingsMedicationCtrl.text,
            }
          : null,
    });
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
                  // Informational text
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: lightBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Please provide information about any health conditions in your family',
                      style: TextStyle(fontSize: 14, color: darkBlue),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildExpandableSection(
                    title: "Mother's Health History",
                    icon: Icons.woman,
                    isExpanded: _showMotherDetails,
                    onTap: () => setState(() => _showMotherDetails = !_showMotherDetails),
                    children: [
                      _buildHealthHistoryFields(
                        hasCondition: 'Does your mother have any health conditions?',
                        detailsLabel: "Mother's condition details",
                        diagnosisLabel: 'Year of diagnosis',
                        medicationLabel: 'Current medications',
                        hasConditionValue: _motherHasCondition,
                        onSwitchChanged: (val) => setState(() => _motherHasCondition = val),
                        conditionCtrl: _motherConditionCtrl,
                        yearCtrl: _motherYearCtrl,
                        medicationCtrl: _motherMedicationCtrl,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _buildExpandableSection(
                    title: "Father's Health History",
                    icon: Icons.man,
                    isExpanded: _showFatherDetails,
                    onTap: () => setState(() => _showFatherDetails = !_showFatherDetails),
                    children: [
                      _buildHealthHistoryFields(
                        hasCondition: 'Does your father have any health conditions?',
                        detailsLabel: "Father's condition details",
                        diagnosisLabel: 'Year of diagnosis',
                        medicationLabel: 'Current medications',
                        hasConditionValue: _fatherHasCondition,
                        onSwitchChanged: (val) => setState(() => _fatherHasCondition = val),
                        conditionCtrl: _fatherConditionCtrl,
                        yearCtrl: _fatherYearCtrl,
                        medicationCtrl: _fatherMedicationCtrl,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _buildExpandableSection(
                    title: "Siblings' Health History",
                    icon: Icons.people,
                    isExpanded: _showSiblingsDetails,
                    onTap: () => setState(() => _showSiblingsDetails = !_showSiblingsDetails),
                    children: [
                      _buildHealthHistoryFields(
                        hasCondition: 'Do your siblings have any health conditions?',
                        detailsLabel: "Siblings' condition details",
                        diagnosisLabel: 'Year of diagnosis',
                        medicationLabel: 'Current medications',
                        hasConditionValue: _siblingsHaveCondition,
                        onSwitchChanged: (val) => setState(() => _siblingsHaveCondition = val),
                        conditionCtrl: _siblingsConditionCtrl,
                        yearCtrl: _siblingsYearCtrl,
                        medicationCtrl: _siblingsMedicationCtrl,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _saveDataToFirebase();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: white),
                                  SizedBox(width: 12),
                                  Text('Family history saved successfully'),
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
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text(
                        'Save Family History',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isExpanded ? lightBlue.withOpacity(0.2) : white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isExpanded ? primaryBlue.withOpacity(0.5) : lightBlue,
          width: isExpanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            splashColor: lightBlue,
            highlightColor: lightBlue.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(icon, color: primaryBlue, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkBlue),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: Icon(Icons.keyboard_arrow_down, color: primaryBlue, size: 28),
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      child: Column(children: children),
                    )
                  : SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthHistoryFields({
    required String hasCondition,
    required String detailsLabel,
    required String diagnosisLabel,
    required String medicationLabel,
    required bool hasConditionValue,
    required Function(bool) onSwitchChanged,
    required TextEditingController conditionCtrl,
    required TextEditingController yearCtrl,
    required TextEditingController medicationCtrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text(hasCondition, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: darkBlue)),
          value: hasConditionValue,
          onChanged: onSwitchChanged,
          contentPadding: EdgeInsets.zero,
          activeColor: primaryBlue,
          activeTrackColor: lightBlue,
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 300),
          child: hasConditionValue
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: conditionCtrl,
                      decoration: _buildInputDecoration(detailsLabel, 'e.g., Diabetes, Heart Disease', Icons.medical_information),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: yearCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration(diagnosisLabel, 'YYYY', Icons.calendar_today),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: medicationCtrl,
                            decoration: _buildInputDecoration(medicationLabel, 'Optional', Icons.medication),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: primaryBlue),
      hintText: hint,
      hintStyle: TextStyle(color: darkBlue.withOpacity(0.5)),
      prefixIcon: Icon(icon, color: primaryBlue),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: lightBlue)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryBlue, width: 2)),
      filled: true,
      fillColor: white,
    );
  }
}
