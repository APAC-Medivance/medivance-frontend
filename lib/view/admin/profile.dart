import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

// Doctor Admin Profile View Page that appears first when tapping doctor admin profile icon
class DoctorProfileViewPage extends StatefulWidget {
  const DoctorProfileViewPage({Key? key}) : super(key: key);

  @override
  _DoctorProfileViewPageState createState() => _DoctorProfileViewPageState();
}

class _DoctorProfileViewPageState extends State<DoctorProfileViewPage> {
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
  bool isLoading = true;
  bool hasCompleteData = false;
  String specialty = '';

  @override
  void initState() {
    super.initState();
    _loadDoctorProfile();
  }

  Future<void> _loadDoctorProfile() async {
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
      final profileSnapshot = await _database.ref('doctor_profiles/${user.uid}').get();
      if (profileSnapshot.exists) {
        setState(() {
          profileData = Map<String, dynamic>.from(profileSnapshot.value as Map);
          
          // Check if all required fields have data
          hasCompleteData = _checkProfileCompleteness();
          
          // Get specialty
          specialty = profileData?['specialty'] ?? 'General Medicine';
        });
      } else {
        setState(() {
          profileData = {
            'email': user.email ?? '',
          };
          hasCompleteData = false;
        });
      }
      
      // Note: In a real app, you would also fetch the profile image from Firebase Storage here
      
    } catch (e) {
      print('Error loading doctor profile: $e');
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
        profileData!['address'] != null &&
        profileData!['age'] != null &&
        profileData!['gender'] != null &&
        profileData!['phone'] != null;
  }

  void _navigateToEditProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DoctorProfileInputPage(
          existingData: profileData,
          onProfileUpdated: () {
            _loadDoctorProfile(); // Reload data when coming back
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: lightBlue,
        appBar: AppBar(
          title: Text('Doctor Profile'),
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
        title: Text('Doctor Profile'),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header with avatar and name
            Container(
              padding: EdgeInsets.all(20),
              color: lightBlue,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[100],
                          backgroundImage: profileImage != null
                              ? FileImage(profileImage!)
                              : null,
                          child: profileImage == null
                              ? Icon(Icons.person, size: 60, color: darkBlue)
                              : null,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Dr. ${profileData?['name'] ?? 'Your name'}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          specialty,
                          style: TextStyle(
                            fontSize: 18,
                            color: darkBlue.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
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
                    // Doctor ID and License
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Doctor ID
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.badge, color: primaryBlue),
                              SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  'ID: ${profileData?['doctorId'] ?? 'Not set'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // License
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.card_membership, color: primaryBlue),
                              SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  'License: ${profileData?['licenseNumber'] ?? 'Not set'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Address row
                    Row(
                      children: [
                        Icon(Icons.location_on, color: primaryBlue),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            profileData?['address'] ?? 'Address not set',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
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
            
            // Specialty & Experience Card 
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Professional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Specialty
                    Row(
                      children: [
                        Icon(Icons.medical_services, color: primaryBlue),
                        SizedBox(width: 12),
                        Text(
                          'Specialty: ${profileData?['specialty'] ?? 'Not set'}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Experience
                    Row(
                      children: [
                        Icon(Icons.work, color: primaryBlue),
                        SizedBox(width: 12),
                        Text(
                          'Experience: ${profileData?['experience'] ?? '0'} years',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Qualification
                    Row(
                      children: [
                        Icon(Icons.school, color: primaryBlue),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Qualification: ${profileData?['qualification'] ?? 'Not set'}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Doctor Profile Input Page
class DoctorProfileInputPage extends StatefulWidget {
  final Map<String, dynamic>? existingData;
  final Function onProfileUpdated;

  DoctorProfileInputPage({
    this.existingData,
    required this.onProfileUpdated,
  });

  @override
  _DoctorProfileInputPageState createState() => _DoctorProfileInputPageState();
}

class _DoctorProfileInputPageState extends State<DoctorProfileInputPage> {
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
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _doctorIdController;
  late TextEditingController _licenseNumberController;
  late TextEditingController _qualificationController;
  late TextEditingController _experienceController;

  // Form data
  File? _profileImage;
  late String _gender;
  String _userEmail = '';
  late String _specialty;

  // List of medical specialties for dropdown
  final List<String> _specialties = [
    'General Medicine',
    'Family Medicine',
    'Pediatrics',
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Obstetrics & Gynecology',
    'Ophthalmology',
    'Orthopedics',
    'Psychiatry',
    'Surgery',
    'Emergency Medicine',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _initializeFormData();
    _getUserEmail();
  }

  void _initializeFormData() {
    final data = widget.existingData;

    // Initialize controllers with existing data if available
    _nameController = TextEditingController(text: data?['name'] ?? '');
    _addressController = TextEditingController(text: data?['address'] ?? '');
    _phoneController = TextEditingController(text: data?['phone'] ?? '');
    _ageController = TextEditingController(text: data?['age']?.toString() ?? '');
    _doctorIdController = TextEditingController(text: data?['doctorId'] ?? '');
    _licenseNumberController = TextEditingController(text: data?['licenseNumber'] ?? '');
    _qualificationController = TextEditingController(text: data?['qualification'] ?? '');
    _experienceController = TextEditingController(text: data?['experience']?.toString() ?? '');

    // Initialize other form fields
    _gender = data?['gender'] ?? 'Male';
    _specialty = data?['specialty'] ?? 'General Medicine';
  }

  void _getUserEmail() {
    final User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? '';
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

  Future<void> _saveProfile() async {
    try {
      // Validate inputs
      if (_nameController.text.isEmpty ||
          _addressController.text.isEmpty ||
          _phoneController.text.isEmpty ||
          _ageController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all required fields')),
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
        'address': _addressController.text,
        'phone': _phoneController.text,
        'gender': _gender,
        'age': int.tryParse(_ageController.text) ?? 0,
        'email': _userEmail,
        'doctorId': _doctorIdController.text,
        'licenseNumber': _licenseNumberController.text,
        'specialty': _specialty,
        'qualification': _qualificationController.text,
        'experience': int.tryParse(_experienceController.text) ?? 0,
        'timestamp': ServerValue.timestamp,
        // We would normally upload the image to Storage and save URL here
        'hasProfileImage': _profileImage != null,
      };
      
      // Save to database
      await _database.ref('doctor_profiles/${user.uid}').set(profileData);

      // Upload profile image to Firebase Storage (not implemented in this code)
      // This would be where you'd upload the _profileImage file to Firebase Storage
      // and then update the profileData with the download URL
      
      // Notify that profile was updated
      widget.onProfileUpdated();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Doctor profile updated successfully')),
      );
      
      // Return to profile view
      Navigator.of(context).pop();
      
    } catch (e) {
      print('Error saving doctor profile: $e');
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
        title: Text('Edit Doctor Profile'),
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
                      radius: 60,
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
                    
                    // Address Field
                    TextField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.location_on, color: primaryBlue),
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
                    
                    // Gender and Age Row
                    Row(
                      children: [
                        // Gender Selection
                        Expanded(
                          child: DropdownButtonFormField<String>(
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
                        ),
                        SizedBox(width: 12),
                        // Age Field
                        Expanded(
                          child: TextField(
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
            
            // Professional Information Section
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
                      'Professional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Doctor ID and License Number Row
                    Row(
                      children: [
                        // Doctor ID
                        Expanded(
                          child: TextField(
                            controller: _doctorIdController,
                            decoration: InputDecoration(
                              labelText: 'Doctor ID',
                              prefixIcon: Icon(Icons.badge, color: primaryBlue),
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
                        // License Number
                        Expanded(
                          child: TextField(
                            controller: _licenseNumberController,
                            decoration: InputDecoration(
                              labelText: 'License Number',
                              prefixIcon: Icon(Icons.card_membership, color: primaryBlue),
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
                    SizedBox(height: 16),
                    
                    // Specialty Selection
                    DropdownButtonFormField<String>(
                      value: _specialty,
                      decoration: InputDecoration(
                        labelText: 'Specialty',
                        prefixIcon: Icon(Icons.medical_services, color: primaryBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: primaryBlue, width: 2),
                        ),
                      ),
                      items: _specialties
                          .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _specialty = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Qualification and Experience Row
                    Row(
                      children: [
                        // Qualification
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _qualificationController,
                            decoration: InputDecoration(
                              labelText: 'Qualification',
                                                          prefixIcon: Icon(Icons.school),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        // Experience
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _experienceController,
                            decoration: InputDecoration(
                              labelText: 'Experience (years)',
                              prefixIcon: Icon(Icons.work),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
  
                    SizedBox(height: 16),
                    
                // Save Button
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: Text('Save Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue, // ganti 'primary' dengan 'backgroundColor'
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
      ));
  }}