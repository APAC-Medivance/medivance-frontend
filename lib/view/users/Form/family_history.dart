import 'package:flutter/material.dart';

class FamilyHistoryForm extends StatefulWidget {
  @override
  _FamilyHistoryFormState createState() => _FamilyHistoryFormState();
}

class _FamilyHistoryFormState extends State<FamilyHistoryForm> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Theme colors - Blue and White theme
  final Color primaryBlue = Color.fromARGB(255, 95, 175, 255);
  final Color lightBlue = Color(0xFFBBDEFB);
  final Color darkBlue = Color.fromARGB(255, 91, 153, 246);
  final Color white = Colors.white;
  
  final _formKey = GlobalKey<FormState>();
  bool _showMotherDetails = true;
  bool _showFatherDetails = true;
  bool _showSiblingsDetails = true;

  // State for switches
  bool _motherHasCondition = false;
  bool _fatherHasCondition = false;
  bool _siblingsHaveCondition = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                      // Icon(Icons.family_restroom, color: primaryBlue, size: 28),
                      // const SizedBox(width: 12),
                      // Text(
                      //   'Family Medical History',
                      //   style: TextStyle(
                      //     fontSize: 15,
                      //     fontWeight: FontWeight.bold,
                      //     color: primaryBlue,
                      //     letterSpacing: 0.5,
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: lightBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Please provide information about any health conditions in your family',
                      style: TextStyle(
                        fontSize: 14,
                        color: darkBlue,
                      ),
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
                        onSwitchChanged: (value) {
                          setState(() {
                            _motherHasCondition = value;
                          });
                        },
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
                        onSwitchChanged: (value) {
                          setState(() {
                            _fatherHasCondition = value;
                          });
                        },
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
                        onSwitchChanged: (value) {
                          setState(() {
                            _siblingsHaveCondition = value;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.9, end: 1.0),
                    duration: Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Save form data
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
                          'Save Family History',
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
        boxShadow: isExpanded 
            ? [BoxShadow(color: primaryBlue.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 3))]
            : null,
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkBlue,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: primaryBlue,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: 16.0,
                      ),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text(
            hasCondition,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: darkBlue,
            ),
          ),
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
                      decoration: InputDecoration(
                        labelText: detailsLabel,
                        labelStyle: TextStyle(color: primaryBlue),
                        hintText: 'e.g., Diabetes, Heart Disease',
                        hintStyle: TextStyle(color: darkBlue.withOpacity(0.5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: lightBlue),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: primaryBlue,
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(Icons.medical_information, color: primaryBlue),
                        filled: true,
                        fillColor: white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: lightBlue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: diagnosisLabel,
                              labelStyle: TextStyle(color: primaryBlue),
                              hintText: 'YYYY',
                              hintStyle: TextStyle(color: darkBlue.withOpacity(0.5)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.calendar_today, color: primaryBlue),
                              filled: true,
                              fillColor: white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: lightBlue),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryBlue, width: 2),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: medicationLabel,
                              labelStyle: TextStyle(color: primaryBlue),
                              hintText: 'Optional',
                              hintStyle: TextStyle(color: darkBlue.withOpacity(0.5)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.medication, color: primaryBlue),
                              filled: true,
                              fillColor: white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: lightBlue),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryBlue, width: 2),
                              ),
                            ),
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
}