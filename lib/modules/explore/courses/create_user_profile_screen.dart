import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/providers/create_user_profile_provider.dart';
import 'package:linkschool/modules/model/cbt_user_model.dart';


class CreateUserProfileScreen extends StatefulWidget {
  final String userId;
  final CbtUserProfile? profile;
  final CbtUserProfile? existingProfile;
  const CreateUserProfileScreen({
    super.key,
    required this.userId,
    this.profile,  this.existingProfile,
  });

  @override
  State<CreateUserProfileScreen> createState() =>
      _CreateUserProfileScreenState();
}

class _CreateUserProfileScreenState extends State<CreateUserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  String? _errorMessage;
  DateTime? _selectedDob;
  String? _selectedGender;



  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.profile != null || widget.existingProfile != null;

  @override
  void initState() {
    super.initState();
    // Use profile if available, fallback to existingProfile
    final profile = widget.profile ?? widget.existingProfile;
    if (profile != null) {
      _firstNameController.text = profile.firstName ?? '';
      _lastNameController.text = profile.lastName ?? '';
     
      
      if (profile.birthDate != null && profile.birthDate!.isNotEmpty) {
        _dobController.text = profile.birthDate!;
        _selectedDob = DateTime.tryParse(profile.birthDate!);
      }
      
      if (profile.gender != null && profile.gender!.isNotEmpty) {
        _selectedGender = profile.gender!.toLowerCase();
      }
    }
  }

  // initialize profile details if editing existing profile
  

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initialDate =
        _selectedDob ?? DateTime(now.year - 12, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _selectedDob = picked;
      _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    final profileData = {
      "user_id": widget.userId,
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'birth_date': _dobController.text.trim(),
      'gender': _selectedGender,
    };

    try {
      final provider = context.read<CreateUserProfileProvider>();
      final profileToEdit = widget.profile ?? widget.existingProfile;
  //  adding user id to profile data
      final String userId = widget.userId;
      profileData['user_id'] = userId;
      final profiles = (_isEditing && profileToEdit?.id != null)
          ? await provider.updateUserProfile(
              profileToEdit!.id!.toString(),
              profileData,
              
            )
          : await provider.createUserProfile(profileData, widget.userId);

      final cbtUserProvider =
          Provider.of<CbtUserProvider>(context, listen: false);
      if (profiles.isNotEmpty) {
        await cbtUserProvider.replaceProfiles(profiles);
      }

      if (!mounted) return;
      final successMessage = _isEditing
          ? 'Profile updated successfully!'
          : 'Profile created successfully!';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to create profile';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<CreateUserProfileProvider>().isLoading;
    final screenTitle = _isEditing ? 'Edit Profile' : 'Create New Profile';
    final actionLabel = _isEditing ? 'Update Profile' : 'Create Profile';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          screenTitle,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Profile Picture Avatar
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // First Name Field
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name *',
                  hintText: 'Enter your first name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFA500),
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),

              // Last Name Field
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name *',
                  hintText: 'Enter your last name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFA500),
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),


              // // Email Field
              // TextFormField(
              //   controller: _emailController,
              //   decoration: InputDecoration(
              //     labelText: 'Email Address *',
              //     hintText: 'Enter your email',
              //     prefixIcon: const Icon(Icons.email_outlined),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     enabledBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: BorderSide(color: Colors.grey.shade300),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: const BorderSide(
              //         color: Color(0xFFFFA500),
              //         width: 2,
              //       ),
              //     ),
              //   ),
              //   keyboardType: TextInputType.emailAddress,
              //   validator: (value) {
              //     if (value == null || value.trim().isEmpty) {
              //       return 'Please enter your email';
              //     }
              //     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
              //         .hasMatch(value.trim())) {
              //       return 'Please enter a valid email address';
              //     }
              //     return null;
              //   },
              // ),
              // const SizedBox(height: 20),

              // Date of Birth Field
              TextFormField(
                controller: _dobController,
                readOnly: true,
                onTap: _pickDateOfBirth,
                decoration: InputDecoration(
                  labelText: 'Date of Birth *',
                  hintText: 'Select your date of birth',
                  prefixIcon: const Icon(Icons.cake_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFA500),
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select your date of birth';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: 'Gender *',
                  prefixIcon: const Icon(Icons.wc_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFA500),
                      width: 2,
                    ),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              // const SizedBox(height: 20),
              // // Phone Number Field
              // TextFormField(
              //   controller: _phoneController,
              //   decoration: InputDecoration(
              //     labelText: 'Phone Number *',
              //     hintText: 'Enter your phone number',
              //     prefixIcon: const Icon(Icons.phone_outlined),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     enabledBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: BorderSide(color: Colors.grey.shade300),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: const BorderSide(
              //         color: Color(0xFFFFA500),
              //         width: 2,
              //       ),
              //     ),
              //   ),
              //   keyboardType: TextInputType.phone,
              //   validator: (value) {
              //     if (value == null || value.trim().isEmpty) {
              //       return 'Please enter your phone number';
              //     }
              //     // Basic phone validation - at least 10 digits
              //     final phoneDigits = value.replaceAll(RegExp(r'[^\d]'), '');
              //     if (phoneDigits.length < 10) {
              //       return 'Please enter a valid phone number';
              //     }
              //     return null;
              //   },
              // ),
               const SizedBox(height: 30),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),

              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          actionLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}







