import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Account Information Controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Personal Information Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _studentIdController = TextEditingController();
  String _selectedGender = 'Male';

  // Medical Information Controllers
  final _bloodTypeController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _currentMedicationsController = TextEditingController();
  final _immunizationHistoryController = TextEditingController();
  final _medicalDevicesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Dispose all controllers
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _studentIdController.dispose();
    _bloodTypeController.dispose();
    _emergencyContactController.dispose();
    _medicalConditionsController.dispose();
    _allergiesController.dispose();
    _currentMedicationsController.dispose();
    _immunizationHistoryController.dispose();
    _medicalDevicesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Account'),
            Tab(text: 'Personal'),
            Tab(text: 'Medical'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAccountTab(),
            _buildPersonalTab(),
            _buildMedicalTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person, color: Colors.red),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Username is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email, color: Colors.red),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value?.isEmpty == true ? 'Email is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock, color: Colors.red),
                    ),
                    obscureText: true,
                    validator: (value) => value?.isEmpty == true ? 'Password is required' : null,
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_validateCurrentTab()) {
                _tabController.animateTo(1);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline, color: Colors.red),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'First name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline, color: Colors.red),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Last name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dateOfBirthController,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today, color: Colors.red),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        _dateOfBirthController.text = '${date.day}/${date.month}/${date.year}';
                      }
                    },
                    validator: (value) => value?.isEmpty == true ? 'Date of birth is required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person, color: Colors.red),
                    ),
                    items: ['Male', 'Female', 'Other'].map((gender) {
                      return DropdownMenuItem(value: gender, child: Text(gender));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedGender = value!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _studentIdController,
                    decoration: const InputDecoration(
                      labelText: 'Student ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge, color: Colors.red),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Student ID is required' : null,
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_validateCurrentTab()) {
                _tabController.animateTo(2);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bloodTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Blood Type (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.water_drop, color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emergencyContactController,
                    decoration: const InputDecoration(
                      labelText: 'Emergency Contact',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.emergency, color: Colors.red),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value?.isEmpty == true ? 'Emergency contact is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _medicalConditionsController,
                    decoration: const InputDecoration(
                      labelText: 'Medical Conditions (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medical_services, color: Colors.red),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _allergiesController,
                    decoration: const InputDecoration(
                      labelText: 'Allergies (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.warning, color: Colors.red),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _currentMedicationsController,
                    decoration: const InputDecoration(
                      labelText: 'Current Medications (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medication, color: Colors.red),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _immunizationHistoryController,
                    decoration: const InputDecoration(
                      labelText: 'Immunization History (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.vaccines, color: Colors.red),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _medicalDevicesController,
                    decoration: const InputDecoration(
                      labelText: 'Medical Devices (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.devices_other, color: Colors.red),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_validateCurrentTab()) {
                await _submitRegistration();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Complete Registration'),
          ),
        ],
      ),
    );
  }

  bool _validateCurrentTab() {
    final currentIndex = _tabController.index;
    
    // Use form validation
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    bool isValid = true;
    String errorMessage = 'Please fill in all required fields';

    if (currentIndex == 0) {
      // Validate account information - all required
      if (_usernameController.text.trim().isEmpty) {
        errorMessage = 'Username is required';
        isValid = false;
      } else if (_emailController.text.trim().isEmpty) {
        errorMessage = 'Email is required';
        isValid = false;
      } else if (!_isValidEmail(_emailController.text.trim())) {
        errorMessage = 'Please enter a valid email address';
        isValid = false;
      } else if (_passwordController.text.isEmpty) {
        errorMessage = 'Password is required';
        isValid = false;
      } else if (_passwordController.text.length < 6) {
        errorMessage = 'Password must be at least 6 characters long';
        isValid = false;
      }
    } else if (currentIndex == 1) {
      // Validate personal information - all required
      if (_firstNameController.text.trim().isEmpty) {
        errorMessage = 'First name is required';
        isValid = false;
      } else if (_lastNameController.text.trim().isEmpty) {
        errorMessage = 'Last name is required';
        isValid = false;
      } else if (_dateOfBirthController.text.isEmpty) {
        errorMessage = 'Date of birth is required';
        isValid = false;
      } else if (_studentIdController.text.trim().isEmpty) {
        errorMessage = 'Student ID is required';
        isValid = false;
      }
    } else if (currentIndex == 2) {
      // Validate medical information - only emergency contact is required
      if (_emergencyContactController.text.trim().isEmpty) {
        errorMessage = 'Emergency contact is required';
        isValid = false;
      } else if (!_isValidPhoneNumber(_emergencyContactController.text.trim())) {
        errorMessage = 'Please enter a valid phone number';
        isValid = false;
      }
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    return isValid;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhoneNumber(String phone) {
    // Basic phone validation - adjust regex as needed for your requirements
    return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  Future<void> _submitRegistration() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.red),
              SizedBox(width: 20),
              Text("Creating your account..."),
            ],
          ),
        );
      },
    );

    try {
      const String apiUrl = 'http://206.189.90.136:3000/api/register';
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'dateOfBirth': _dateOfBirthController.text,
          'gender': _selectedGender,
          'studentId': _studentIdController.text.trim(),
          'bloodType': _bloodTypeController.text.trim().isEmpty ? null : _bloodTypeController.text.trim(),
          'emergencyContact': _emergencyContactController.text.trim(),
          'medicalConditions': _medicalConditionsController.text.trim().isEmpty ? null : _medicalConditionsController.text.trim(),
          'allergies': _allergiesController.text.trim().isEmpty ? null : _allergiesController.text.trim(),
          'currentMedications': _currentMedicationsController.text.trim().isEmpty ? null : _currentMedicationsController.text.trim(),
          'immunizationHistory': _immunizationHistoryController.text.trim().isEmpty ? null : _immunizationHistoryController.text.trim(),
          'medicalDevices': _medicalDevicesController.text.trim().isEmpty ? null : _medicalDevicesController.text.trim(),
        }),
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              icon: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              title: const Text(
                'Account Created Successfully!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome to TapCare, ${_firstNameController.text}!',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your account has been created successfully. You can now login with your credentials.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to main page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Continue to Login'),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        final responseData = jsonDecode(response.body);
        _showErrorDialog(responseData['message'] ?? 'Registration failed. Please try again.');
      }
    } catch (error) {
      // Close loading dialog if still open
      Navigator.of(context).pop();
      _showErrorDialog('Network error. Please check your internet connection and try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(
            Icons.error,
            color: Colors.red,
            size: 64,
          ),
          title: const Text(
            'Registration Failed',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Try Again'),
              ),
            ),
          ],
        );
      },
    );
  }
}
