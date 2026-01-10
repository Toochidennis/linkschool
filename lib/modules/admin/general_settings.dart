import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GeneralSettingsScreen extends StatefulWidget {
  const GeneralSettingsScreen({super.key});

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  // Controllers for form fields
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _academicYearController = TextEditingController();
  final TextEditingController _academicTermController = TextEditingController();
  final TextEditingController _mottoController = TextEditingController();
  final TextEditingController _shortNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _studentFeeController = TextEditingController();
  final TextEditingController _examFeeController = TextEditingController();
  final TextEditingController _adminCodeController = TextEditingController();

  // Profile image variables
  File? _selectedImage;
  String? _base64Image;
  bool _isLoading = false;

  // Dropdown values
  String? _selectedAcademicYear;
  String? _selectedAcademicTerm;

  final List<String> _academicYears = [
    '2023/2024',
    '2024/2025',
    '2025/2026',
    '2026/2027',
  ];

  final List<String> _academicTerms = [
    '1st Term',
    '2nd Term',
    '3rd Term',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  @override
  void dispose() {
    // Dispose all controllers
    _schoolNameController.dispose();
    _academicYearController.dispose();
    _academicTermController.dispose();
    _mottoController.dispose();
    _shortNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _studentFeeController.dispose();
    _examFeeController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingData() async {
    // Load existing settings data here
    // This would typically come from your database or API
    setState(() {
      _schoolNameController.text = "LITTLE ANGELS BRITISH SCHOOLS";
      _selectedAcademicYear = "2023/2024";
      _selectedAcademicTerm = "1st Term";
      // Add other default values as needed
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _isLoading = true;
        });

        final File imageFile = File(image.path);
        final Uint8List imageBytes = await imageFile.readAsBytes();
        final String base64String = base64Encode(imageBytes);

        setState(() {
          _selectedImage = imageFile;
          _base64Image = base64String;
          _isLoading = false;
        });

        _showSnackBar('Profile image uploaded successfully!', Colors.green);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Failed to upload image: ${e.toString()}', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Urbanist'),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Prepare data to save
        final Map<String, dynamic> settingsData = {
          'school_name': _schoolNameController.text,
          'academic_year': _selectedAcademicYear,
          'academic_term': _selectedAcademicTerm,
          'motto': _mottoController.text,
          'short_name': _shortNameController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'country': _countryController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'student_fee': _studentFeeController.text,
          'exam_fee': _examFeeController.text,
          'admin_code': _adminCodeController.text,
          'profile_image_base64': _base64Image,
        };

        // TODO: Implement API call to save settings
        debugPrint('Settings Data: $settingsData');
        await Future.delayed(const Duration(seconds: 2)); // Simulated API call

        setState(() {
          _isLoading = false;
        });

        _showSnackBar('Settings saved successfully!', Colors.green);
        
        // Print base64 string for debugging (remove in production)
        if (_base64Image != null) {
          debugPrint('Base64 Image Length: ${_base64Image!.length}');
          debugPrint('Base64 Preview: ${_base64Image!.substring(0, 100)}...');
        }
        
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Failed to save settings: ${e.toString()}', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A4FBC),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: const Text(
          'General Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Urbanist',
          ),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Profile Image Uploader
                    _buildProfileImageUploader(),
                    const SizedBox(height: 32),
                    
                    // School Name
                    _buildTextField(
                      controller: _schoolNameController,
                      hintText: 'LITTLE ANGELS BRITISH SCHOOLS',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter school name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Academic Year Dropdown
                    _buildDropdownField(
                      value: _selectedAcademicYear,
                      hintText: '2023/2024',
                      items: _academicYears,
                      onChanged: (value) {
                        setState(() {
                          _selectedAcademicYear = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Academic Term Dropdown
                    _buildDropdownField(
                      value: _selectedAcademicTerm,
                      hintText: '1st Term',
                      items: _academicTerms,
                      onChanged: (value) {
                        setState(() {
                          _selectedAcademicTerm = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Motto
                    _buildTextField(
                      controller: _mottoController,
                      hintText: 'Motto',
                    ),
                    const SizedBox(height: 16),

                    // Short Name
                    _buildTextField(
                      controller: _shortNameController,
                      hintText: 'Short Name',
                    ),
                    const SizedBox(height: 16),

                    // Address
                    _buildTextField(
                      controller: _addressController,
                      hintText: 'Address',
                    ),
                    const SizedBox(height: 16),

                    // City
                    _buildTextField(
                      controller: _cityController,
                      hintText: 'City',
                    ),
                    const SizedBox(height: 16),

                    // State
                    _buildTextField(
                      controller: _stateController,
                      hintText: 'State',
                    ),
                    const SizedBox(height: 16),

                    // Country
                    _buildTextField(
                      controller: _countryController,
                      hintText: 'Country',
                    ),
                    const SizedBox(height: 16),

                    // Email
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    _buildTextField(
                      controller: _phoneController,
                      hintText: 'Phone',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Student Fee
                    _buildTextField(
                      controller: _studentFeeController,
                      hintText: 'Student Fee',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Exam Fee
                    _buildTextField(
                      controller: _examFeeController,
                      hintText: 'Exam Fee',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Admin Code
                    _buildTextField(
                      controller: _adminCodeController,
                      hintText: 'Admin Code',
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Save Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A4FBC),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'SAVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Urbanist',
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageUploader() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: _selectedImage != null
                ? ClipOval(
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    ),
                  )
                : Icon(
                    Icons.school,
                    size: 50,
                    color: Colors.grey[400],
                  ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _isLoading ? null : _pickImage,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A4FBC),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'Urbanist',
        fontSize: 16,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontFamily: 'Urbanist',
          fontSize: 16,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF4A4FBC),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String hintText,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      style: const TextStyle(
        fontFamily: 'Urbanist',
        fontSize: 16,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontFamily: 'Urbanist',
          fontSize: 16,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF4A4FBC),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 16,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: Colors.grey,
      ),
    );
  }
}