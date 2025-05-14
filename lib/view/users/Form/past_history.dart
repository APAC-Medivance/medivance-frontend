import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class PastHistoryForm extends StatefulWidget {
  @override
  _PastHistoryFormState createState() => _PastHistoryFormState();
}

class _PastHistoryFormState extends State<PastHistoryForm> with SingleTickerProviderStateMixin {

  // Firebase database instance with URL region Asia-Southeast1
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://hajjhealth-app-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final primaryBlue = Color.fromARGB(255, 95, 175, 255);
  final lightBlue = Color(0xFFBBDEFB);
  final darkBlue = Color.fromARGB(255, 91, 153, 246);
  final white = Colors.white;

  List<TextEditingController> controllers = [TextEditingController()];

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
    // Dispose all controllers
    for (var controller in controllers) {
      controller.dispose();
    }
    _controller.dispose();
    super.dispose();
  }
  
  void _addField() {
    setState(() {
      controllers.add(TextEditingController());
    });
  }

  void _removeField(int index) {
    setState(() {
      controllers.removeAt(index);
    });
  }

  // Function to save data to Firebase
  Future<void> _saveDataToFirebase() async {
    try {
      final ref = _database.ref('past_history').push(); // generate auto-ID
      
      // Filter out empty entries and collect valid ones
      List<String> medicalHistoryItems = controllers
          .where((c) => c.text.trim().isNotEmpty)
          .map((c) => c.text.trim())
          .toList();
      
      // Build data object
      Map<String, dynamic> medicalHistoryData = {
        'historyItems': medicalHistoryItems,
        'timestamp': ServerValue.timestamp,
      };
      
      // Log data for debugging
      print('Data to save: $medicalHistoryData');
      
      // Save to database
      await ref.set(medicalHistoryData);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: white),
              SizedBox(width: 12),
              Text('Past medical history saved successfully'),
            ],
          ),
          backgroundColor: primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      
      // Navigate back to previous screen after successful save
      Navigator.pop(context);
      
    } catch (e) {
      print('Error saving data: $e');
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: white),
              SizedBox(width: 12),
              Text('Error saving data. Please try again.'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please fill your past medical history:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controllers[index],
                              decoration: InputDecoration(
                                labelText: 'Entry ${index + 1}',
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
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.blue[400]),
                            onPressed: () => _removeField(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addField,
                      icon: Icon(Icons.add, color: Colors.white),
                      label: Text('Add More', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saveDataToFirebase, // Updated to call Firebase save function
                      child: Text('Save', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}