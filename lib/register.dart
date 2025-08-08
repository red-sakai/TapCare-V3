import 'package:flutter/material.dart';

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
            onPressed: () {
              if (_validateCurrentTab()) {
                // TODO: Handle registration submission
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registration completed!')),
                );
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
    bool isValid = true;

    if (currentIndex == 0) {
      // Validate account information - all required
      if (_usernameController.text.isEmpty || 
          _emailController.text.isEmpty || 
          _passwordController.text.isEmpty) {
        isValid = false;
      }
    } else if (currentIndex == 1) {
      // Validate personal information - all required
      if (_firstNameController.text.isEmpty || 
          _lastNameController.text.isEmpty || 
          _dateOfBirthController.text.isEmpty || 
          _studentIdController.text.isEmpty) {
        isValid = false;
      }
    } else if (currentIndex == 2) {
      // Validate medical information - only emergency contact is required
      if (_emergencyContactController.text.isEmpty) {
        isValid = false;
      }
      // All other medical fields are optional
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
    }

    return isValid;
  }
}
