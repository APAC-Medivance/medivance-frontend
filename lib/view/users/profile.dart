import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';

// Profile View Page that appears first when tapping profile icon
class ProfileViewPage extends StatefulWidget {
  const ProfileViewPage({Key? key}) : super(key: key);

  @override
  _ProfileViewPageState createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://hajjhealth-app-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  // Theme colors
  final Color primaryBlue = Color.fromARGB(255, 95, 175, 255);
  final Color lightBlue = Color(0xFFE3F2FD);
  final Color darkBlue = Color.fromARGB(255, 91, 153, 246);
  final Color white = Colors.white;
  
  // Profile data
  Map<String, dynamic>? profileData;
  File? profileImage;
  String medicalHistory = '';
  bool isLoading = true;
  bool hasCompleteData = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get current user
      final User? user = _auth.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
          hasCompleteData = false;
        });
        return;
      }

      // Fetch profile data
      final profileSnapshot = await _database.ref('user_profiles/${user.uid}').get();
      if (profileSnapshot.exists) {
        setState(() {
          profileData = Map<String, dynamic>.from(profileSnapshot.value as Map);
          
          // Check if all required fields have data
          hasCompleteData = _checkProfileCompleteness();
        });
      } else {
        setState(() {
          profileData = {
            'email': user.email ?? '',
          };
          hasCompleteData = false;
        });
      }

      // Fetch medical history
      await _fetchMedicalHistory();

      // Note: In a real app, you would also fetch the profile image from Firebase Storage here
      
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _checkProfileCompleteness() {
    // Check if all essential fields have data
    return profileData != null &&
        profileData!['name'] != null &&
        profileData!['birthdate'] != null &&
        profileData!['height'] != null &&
        profileData!['weight'] != null &&
        profileData!['phone'] != null;
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
            medicalHistory = 'The patient is a female with the following conditions: '
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

  void _navigateToEditProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileInputPage(
          existingData: profileData,
          onProfileUpdated: () {
            _loadUserProfile(); // Reload data when coming back
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = Color.fromARGB(255, 95, 175, 255);
    final Color lightBlue = Color(0xFFE3F2FD);
    final Color darkBlue = Color.fromARGB(255, 91, 153, 246);
    final Color white = Colors.white;

    if (isLoading) {
      return Scaffold(
        backgroundColor: lightBlue,
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: primaryBlue,
          foregroundColor: white,
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(color: primaryBlue),
        ),
      );
    }

    return Scaffold(
      backgroundColor: lightBlue,
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: primaryBlue,
        foregroundColor: white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _navigateToEditProfile,
            tooltip: 'Edit Profile',
          ),
        ],
      ),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile header with avatar and name
              Container(
                padding: EdgeInsets.all(20),
                // color: lightBlue,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[100],
                            backgroundImage: profileImage != null
                                ? FileImage(profileImage!)
                                : null,
                            child: profileImage == null
                                ? Icon(Icons.person, size: 50, color: darkBlue)
                                : null,
                          ),
                          SizedBox(height: 16),
                          Text(
                            profileData?['name'] ?? 'Your name',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: darkBlue,
                            ),
                          ),
                        ],
                      ),
                      
                      // Warning icon when data is incomplete
                      if (!hasCompleteData)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber[700],
                              shape: BoxShape.circle,
                            ),
                            child: Tooltip(
                              message: 'Please complete your profile',
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Basic info card
              Card(
                color: Colors.white,
                margin: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Date and Height
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Date
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: primaryBlue),
                                SizedBox(width: 12),
                                Text(
                                  profileData?['birthdate'] ?? 'Not set',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Height
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.height, color: primaryBlue),
                                SizedBox(width: 12),
                                Text(
                                  profileData?['height'] != null ? '${profileData!['height']} cm' : 'Not set',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Location and Weight
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Location
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.location_on, color: primaryBlue),
                                SizedBox(width: 12),
                                Text(
                                  profileData?['location'] ?? 'Not set',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Weight
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.fitness_center, color: primaryBlue),
                                SizedBox(width: 12),
                                Text(
                                  profileData?['weight'] != null ? '${profileData!['weight']} kg' : 'Not set',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Contact info card
              Card(
                color: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Phone
                      Row(
                        children: [
                          Icon(Icons.phone, color: primaryBlue),
                          SizedBox(width: 12),
                          Text(
                            profileData?['phone'] ?? 'Not set',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Email
                      Row(
                        children: [
                          Icon(Icons.email, color: primaryBlue),
                          SizedBox(width: 12),
                          Text(
                            profileData?['email'] ?? 'Not set',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Gender
                      Row(
                        children: [
                          Icon(Icons.people, color: primaryBlue),
                          SizedBox(width: 12),
                          Text(
                            profileData?['gender'] ?? 'Not set',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Age
                      Row(
                        children: [
                          Icon(Icons.cake, color: primaryBlue),
                          SizedBox(width: 12),
                          Text(
                            profileData?['age'] != null ? 'Age ${profileData!['age']}' : 'Age not set',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Medical History Card
              Card(
                color : Colors.white,
                margin: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medical History',
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
          ),
        ),
      ),
    );
  }
}

class ProfileInputPage extends StatefulWidget {
  final Map<String, dynamic>? existingData;
  final Function onProfileUpdated;

  ProfileInputPage({
    this.existingData,
    required this.onProfileUpdated,
  });

  @override
  _ProfileInputPageState createState() => _ProfileInputPageState();
}

class _ProfileInputPageState extends State<ProfileInputPage> {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://hajjhealth-app-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  // Theme colors
  final Color primaryBlue = Color.fromARGB(255, 95, 175, 255);
  final Color lightBlue = Color(0xFFBBDEFB);
  final Color darkBlue = Color.fromARGB(255, 91, 153, 246);
  final Color white = Colors.white;
  final Color lightBackground = Color(0xFFE3F2FD);

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;

  // Form data
  File? _profileImage;
  late DateTime _selectedDate;
  late String _gender;
  late String _location;
  late LatLng _selectedLocation;
  String _userEmail = '';
  String _medicalHistory = '';

  @override
  void initState() {
    super.initState();
    _initializeFormData();
    _getUserEmail();
    _fetchMedicalHistory();
  }

  void _initializeFormData() {
    final data = widget.existingData;

    // Initialize controllers with existing data if available
    _nameController = TextEditingController(text: data?['name'] ?? '');
    _heightController = TextEditingController(text: data?['height']?.toString() ?? '');
    _weightController = TextEditingController(text: data?['weight']?.toString() ?? '');
    _phoneController = TextEditingController(text: data?['phone'] ?? '');
    _ageController = TextEditingController(text: data?['age']?.toString() ?? '');

    // Initialize other form fields
    _selectedDate = data?['birthdate'] != null 
      ? DateFormat('dd MMM yyyy').parse(data!['birthdate'])
      : DateTime.now();
    
    _gender = data?['gender'] ?? 'Male';
    _location = data?['location'] ?? 'Mecca';
    
    _selectedLocation = data?['latitude'] != null && data?['longitude'] != null
      ? LatLng(data!['latitude'], data!['longitude'])
      : LatLng(21.4225, 39.8262); // Default to Mecca
  }

  void _getUserEmail() {
    final User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? '';
      });
    }
  }

  Future<void> _fetchMedicalHistory() async {
    try {
      final ref = _database.ref('past_medical_history');
      final snapshot = await ref.limitToLast(1).get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        // Get the first entry (should be the most recent)
        String key = data.keys.first;
        Map<dynamic, dynamic> historyData = data[key];
        
        List<dynamic> historyItems = historyData['historyItems'] ?? [];
        
        setState(() {
          if (historyItems.isEmpty) {
            _medicalHistory = 'No medical history recorded.';
          } else {
            _medicalHistory = 'The patient is a female with the following conditions: '
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
          _medicalHistory = 'No medical history recorded.';
        });
      }
    } catch (e) {
      print('Error fetching medical history: $e');
      setState(() {
        _medicalHistory = 'Error loading medical history.';
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryBlue,
              onPrimary: white,
              onSurface: darkBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectLocation(BuildContext context) async {
    // This would typically open a map for location selection
    // For simplicity, we'll just use a dialog with preset locations
    final locations = {
      'Mecca': LatLng(21.4225, 39.8262),
      'Medina': LatLng(24.5247, 39.5692),
      'Jeddah': LatLng(21.4858, 39.1925),
    };

    String? selectedCity = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Location'),
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: locations.keys.length,
              itemBuilder: (context, index) {
                String city = locations.keys.elementAt(index);
                return ListTile(
                  title: Text(city),
                  onTap: () => Navigator.of(context).pop(city),
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedCity != null) {
      setState(() {
        _location = selectedCity;
        _selectedLocation = locations[selectedCity]!;
      });
    }
  }

  Future<void> _saveProfile() async {
    try {
      // Validate inputs
      if (_nameController.text.isEmpty ||
          _heightController.text.isEmpty ||
          _weightController.text.isEmpty ||
          _phoneController.text.isEmpty ||
          _ageController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all fields')),
        );
        return;
      }

      // Get current user ID
      final User? user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        return;
      }
      
      // Create profile data
      Map<String, dynamic> profileData = {
        'name': _nameController.text,
        'birthdate': DateFormat('dd MMM yyyy').format(_selectedDate),
        'height': int.tryParse(_heightController.text) ?? 0,
        'weight': int.tryParse(_weightController.text) ?? 0,
        'location': _location,
        'latitude': _selectedLocation.latitude,
        'longitude': _selectedLocation.longitude,
        'phone': _phoneController.text,
        'gender': _gender,
        'age': int.tryParse(_ageController.text) ?? 0,
        'email': _userEmail,
        'timestamp': ServerValue.timestamp,
        // We would normally upload the image to Storage and save URL here
        'hasProfileImage': _profileImage != null,
      };
      
      // Save to database
      await _database.ref('user_profiles/${user.uid}').set(profileData);

      // Upload profile image to Firebase Storage (not implemented in this code)
      // This would be where you'd upload the _profileImage file to Firebase Storage
      // and then update the profileData with the download URL
      
      // Notify that profile was updated
      widget.onProfileUpdated();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      
      // Return to profile view
      Navigator.of(context).pop();
      
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: primaryBlue,
        foregroundColor: white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image Section
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: lightBlue,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? Icon(Icons.add_a_photo, size: 40, color: darkBlue)
                          : null,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap to upload photo',
                    style: TextStyle(color: darkBlue),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Personal Information Section
            Card(
              color : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Name Field
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person, color: primaryBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: primaryBlue, width: 2),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Birthday Field
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Birthday',
                            prefixIcon: Icon(Icons.calendar_today, color: primaryBlue),
                            suffixIcon: Icon(Icons.arrow_drop_down, color: primaryBlue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: primaryBlue, width: 2),
                            ),
                          ),
                          controller: TextEditingController(
                            text: DateFormat('dd MMM yyyy').format(_selectedDate),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Height and Weight Row
                    Row(
                      children: [
                        // Height Field
                        Expanded(
                          child: TextField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Height (cm)',
                              prefixIcon: Icon(Icons.height, color: primaryBlue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: primaryBlue, width: 2),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        // Weight Field
                        Expanded(
                          child: TextField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Weight (kg)',
                              prefixIcon: Icon(Icons.fitness_center, color: primaryBlue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: primaryBlue, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Contact Information Section
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Location Field
                    GestureDetector(
                      onTap: () => _selectLocation(context),
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Location',
                            prefixIcon: Icon(Icons.location_on, color: primaryBlue),
                            suffixIcon: Icon(Icons.arrow_drop_down, color: primaryBlue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: primaryBlue, width: 2),
                            ),
                          ),
                          controller: TextEditingController(text: _location),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Phone Field
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone, color: primaryBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: primaryBlue, width: 2),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Email Field (non-editable)
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email, color: primaryBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: primaryBlue, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      controller: TextEditingController(text: _userEmail),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Additional Information Section
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Gender Selection
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: Icon(Icons.people, color: primaryBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: primaryBlue, width: 2),
                        ),
                      ),
                      items: ['Male', 'Female', 'Other']
                          .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _gender = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Age Field
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.cake, color: primaryBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: primaryBlue, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Save Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
