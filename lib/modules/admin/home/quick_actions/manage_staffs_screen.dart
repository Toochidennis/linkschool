import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linkschool/modules/model/admin/home/add_staff_model.dart';
import 'package:linkschool/modules/providers/admin/home/add_staff_provider.dart';
import 'package:provider/provider.dart';
import '../../../common/app_colors.dart';
import '../../../common/constants.dart';
import '../../../common/text_styles.dart';

class ManageStaffScreen extends StatefulWidget {
  const ManageStaffScreen({super.key});

  @override
  State<ManageStaffScreen> createState() => _ManageStaffScreenState();
}

class _ManageStaffScreenState extends State<ManageStaffScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  String? _editingStaffId;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  // Additional controllers for full staff profile
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _religionController = TextEditingController();
  final TextEditingController _lgaOriginController = TextEditingController();
  final TextEditingController _stateOriginController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _homeTownController = TextEditingController();
  final TextEditingController _healthStatusController = TextEditingController();
  final TextEditingController _pastRecordController = TextEditingController();
  final TextEditingController _pastRecordExtraController = TextEditingController();
  final TextEditingController _personalRecordController = TextEditingController();
  final TextEditingController _employmentHistoryController = TextEditingController();
  final TextEditingController _refereesController = TextEditingController();
  final TextEditingController _extraNoteController = TextEditingController();
  final TextEditingController _nextOfKinNameController = TextEditingController();
  final TextEditingController _nextOfKinAddressController = TextEditingController();
  final TextEditingController _nextOfKinEmailController = TextEditingController();
  final TextEditingController _nextOfKinPhoneController = TextEditingController();
  final TextEditingController _employmentDateController = TextEditingController();
  final TextEditingController _healthAppraisalController = TextEditingController();
  final TextEditingController _generalAppraisalController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  
  String _selectedFilter = 'All';
  bool _showAddForm = false;
  bool _isEditing = false;
  String _selectedGender = 'Male';
  String _selectedRole = 'Teacher';
  String _selectedStatus = 'Active';
  String _selectedMaritalStatus = 'single';
  String _selectedAccessLevel = 'staff';
  List<String> _selectedCourses = [];

  // Mock data for staff members
  List<Map<String, dynamic>> _staffList = [
    {
      'id': 'ST001',
      'name': 'Mrs. Sarah Johnson',
      'email': 'sarah.johnson@school.com',
      'phone': '+234 801 234 5678',
      'gender': 'Female',
      'role': 'Teacher',
      'courses': ['Mathematics', 'Physics'],
      'level': 'SSS1',
      'class': 'SSS1A',
      'status': 'Active',
      'joinDate': '2023-01-15',
      'salary': '150,000',
      'address': '123 Victoria Island, Lagos',
    },
    {
      'id': 'ST002',
      'name': 'Mr. David Chen',
      'email': 'david.chen@school.com',
      'phone': '+234 802 345 6789',
      'gender': 'Male',
      'role': 'Teacher',
      'courses': ['English Language', 'Literature'],
      'level': 'JSS2',
      'class': 'JSS2B',
      'status': 'Active',
      'joinDate': '2022-09-01',
      'salary': '140,000',
      'address': '45 Ikeja GRA, Lagos',
    },
    {
      'id': 'ST003',
      'name': 'Dr. Amina Hassan',
      'email': 'amina.hassan@school.com',
      'phone': '+234 803 456 7890',
      'gender': 'Female',
      'role': 'Vice Principal',
      'courses': ['Biology', 'Chemistry'],
      'level': 'SSS2',
      'class': 'SSS2A',
      'status': 'Active',
      'joinDate': '2021-03-10',
      'salary': '250,000',
      'address': '78 Lekki Phase 1, Lagos',
    },
  ];

  // Mock data for courses, levels, and classes
  final List<String> _availableCourses = [
    'Mathematics', 'English Language', 'Physics', 'Chemistry', 'Biology',
    'Geography', 'History', 'Literature', 'Economics', 'Government',
    'Computer Science', 'Agricultural Science', 'Fine Arts', 'Music'
  ];

  final List<String> _availableLevels = [
    'JSS1', 'JSS2', 'JSS3', 'SSS1', 'SSS2', 'SSS3'
  ];

  final Map<String, List<String>> _classesPerLevel = {
    'JSS1': ['JSS1A', 'JSS1B', 'JSS1C'],
    'JSS2': ['JSS2A', 'JSS2B', 'JSS2C'],
    'JSS3': ['JSS3A', 'JSS3B', 'JSS3C'],
    'SSS1': ['SSS1A', 'SSS1B', 'SSS1C'],
    'SSS2': ['SSS2A', 'SSS2B', 'SSS2C'],
    'SSS3': ['SSS3A', 'SSS3B', 'SSS3C'],
  };

  final List<String> _staffRoles = [
    'Teacher', 'Vice Principal', 'Principal', 'Admin Staff', 'Librarian',
    'Lab Assistant', 'Counselor', 'IT Support'
  ];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));


    _fadeController.forward();
    _slideController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
    final provider = Provider.of<AddStaffProvider>(context, listen: false);
    provider.fetchAllStaff();
  });
  }



  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _salaryController.dispose();
    _surnameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _birthDateController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _religionController.dispose();
    _lgaOriginController.dispose();
    _stateOriginController.dispose();
    _nationalityController.dispose();
    _homeTownController.dispose();
    _healthStatusController.dispose();
    _pastRecordController.dispose();
    _pastRecordExtraController.dispose();
    _personalRecordController.dispose();
    _employmentHistoryController.dispose();
    _refereesController.dispose();
    _extraNoteController.dispose();
    _nextOfKinNameController.dispose();
    _nextOfKinAddressController.dispose();
    _nextOfKinEmailController.dispose();
    _nextOfKinPhoneController.dispose();
    _employmentDateController.dispose();
    _healthAppraisalController.dispose();
    _generalAppraisalController.dispose();
    _gradeController.dispose();
    _departmentController.dispose();
    _sectionController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredStaffList {
  final provider = Provider.of<AddStaffProvider>(context, listen: false);
  
  // Convert Staff objects to display maps
  List<Map<String, dynamic>> filtered = provider.staffList
      .map((staff) => staff.toDisplayMap())
      .toList();
  
  if (_selectedFilter != 'All') {
    filtered = filtered.where((staff) => staff['role'] == _selectedFilter).toList();
  }
  
  if (_searchController.text.isNotEmpty) {
    filtered = filtered.where((staff) =>
      staff['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
      staff['email'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
      staff['id'].toString().toLowerCase().contains(_searchController.text.toLowerCase())
    ).toList();
  }
  
  return filtered;
}

  Widget _buildAnimatedCard({
    required Widget child,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.3 + (index * 0.1)),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _slideController,
              curve: Interval(
                index * 0.1,
                1.0,
                curve: Curves.elasticOut,
              ),
            )),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.text6Light, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.text2Light.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.normal700(
              fontSize: 24,
              color: AppColors.text2Light,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.normal400(
              fontSize: 12,
              color: AppColors.text7Light,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.text2Light : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.text2Light : AppColors.text6Light,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.text7Light,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 12,
            fontFamily: 'Urbanist',
          ),
        ),
      ),
    );
  }

  Widget _buildStaffCard(Map<String, dynamic> staff, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.text6Light, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.text2Light.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.text2Light.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  (staff['gender']?.toString().toLowerCase() ?? 'male') == 'male' ? Icons.man : Icons.woman,
                  color: AppColors.text2Light,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff['name'],
                      style: AppTextStyles.normal600(
                        fontSize: 16,
                        color: AppColors.text2Light,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      staff['id'],
                      style: AppTextStyles.normal400(
                        fontSize: 12,
                        color: AppColors.text7Light,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: staff['status'] == 'Active' 
                          ? AppColors.attCheckColor2.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        staff['status'],
                        style: TextStyle(
                          color: staff['status'] == 'Active' 
                            ? AppColors.attCheckColor2
                            : Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _editStaff(index);
                  } else if (value == 'delete') {
                    _deleteStaff(index);
                  } else if (value == 'assign_course') {
                    _showAssignCourseDialog(index);
                  } else if (value == 'assign_class') {
                    _showAssignClassDialog(index);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'assign_course',
                    child: Row(
                      children: [
                        Icon(Icons.book, size: 16),
                        SizedBox(width: 8),
                        Text('Assign Course'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'assign_class',
                    child: Row(
                      children: [
                        Icon(Icons.class_, size: 16),
                        SizedBox(width: 8),
                        Text('Assign Class'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.email, size: 14, color: AppColors.text7Light),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  staff['email'],
                  style: AppTextStyles.normal400(
                    fontSize: 12,
                    color: AppColors.text7Light,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.phone, size: 14, color: AppColors.text7Light),
              const SizedBox(width: 4),
              Text(
                staff['phone'],
                style: AppTextStyles.normal400(
                  fontSize: 12,
                  color: AppColors.text7Light,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.work, size: 14, color: AppColors.text7Light),
              const SizedBox(width: 4),
              Text(
                staff['role'],
                style: AppTextStyles.normal500(
                  fontSize: 12,
                  color: AppColors.text2Light,
                ),
              ),
            ],
          ),
          if (staff['courses'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Courses: ${staff['courses'].join(', ')}',
              style: AppTextStyles.normal400(
                fontSize: 11,
                color: AppColors.attCheckColor2,
              ),
            ),
          ],
          if (staff['class'].isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Class: ${staff['class']} (${staff['level']})',
              style: AppTextStyles.normal400(
                fontSize: 11,
                color: AppColors.secondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddStaffForm() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppColors.text2Light.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.text2Light.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isEditing ? 'Edit Staff Member' : 'Add New Staff',
                style: AppTextStyles.normal600(
                  fontSize: 18,
                  color: AppColors.text2Light,
                ),
              ),
              IconButton(
                onPressed: () {
                  _clearForm();
                  setState(() {
                  _showAddForm = false;
                  _isEditing = false;
                  });
                },
                icon: const Icon(
                  Icons.close,
                  color: AppColors.text5Light,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Names
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _surnameController,
                  label: 'Surname',
                  icon: Icons.badge,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  icon: Icons.person,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _middleNameController,
            label: 'Middle Name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          
          // Email Field
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          
          // Phone Field
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          
          // Birth date
          GestureDetector(
            onTap: () async {
              final now = DateTime.now();
              final initial = DateTime(now.year - 18, now.month, now.day);
              final picked = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: DateTime(1940),
                lastDate: now,
              );
              if (picked != null) {
                _birthDateController.text = picked.toIso8601String().substring(0, 10);
                setState(() {});
              }
            },
            child: AbsorbPointer(
              child: _buildTextField(
                controller: _birthDateController,
                label: 'Birth Date (YYYY-MM-DD)',
                icon: Icons.cake,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Address Field
          _buildTextField(
            controller: _addressController,
            label: 'Address',
            icon: Icons.location_on,
          ),
          const SizedBox(height: 12),

          // City, State, Country
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  icon: Icons.location_city,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _stateController,
                  label: 'State',
                  icon: Icons.map,
                  keyboardType: TextInputType.number
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _countryController,
            label: 'Country',
            icon: Icons.flag,
          ),
          const SizedBox(height: 12),
          
          // Salary Field
          _buildTextField(
            controller: _nationalityController,
            label: 'Nationality',
            icon: Icons.language,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          // Gender Selection
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Gender',
                  value: _selectedGender,
                  items: ['Male', 'Female'],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Role',
                  value: _selectedRole,
                  items: _staffRoles,
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Marital Status and Access Level
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Marital Status',
                  value: _selectedMaritalStatus,
                  items: ['single', 'married', 'divorced', 'widowed'],
                  onChanged: (value) {
                    setState(() {
                      _selectedMaritalStatus = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Access Level',
                  value: _selectedAccessLevel,
                  items: ['admin', 'staff'],
                  onChanged: (value) {
                    setState(() {
                      _selectedAccessLevel = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Origins & Nationality
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _lgaOriginController,
                  label: 'LGA of Origin',
                  icon: Icons.place,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _stateOriginController,
                  label: 'State of Origin',
                  icon: Icons.public,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Expanded(
              //   child: _buildTextField(
              //     controller: _nationalityController,
              //     label: 'Nationality',
              //     icon: ,
              //   ),
              // ),
            
              Expanded(
                child: _buildTextField(
                  controller: _homeTownController,
                  label: 'Home Town',
                  icon: Icons.home,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Religion
          _buildTextField(
            controller: _religionController,
            label: 'Religion',
            icon: Icons.church,
          ),
          const SizedBox(height: 12),

          // Health & Records
          _buildTextField(
            controller: _healthStatusController,
            label: 'Health Status',
            icon: Icons.health_and_safety,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _pastRecordController,
            label: 'Past Record',
            icon: Icons.history,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _pastRecordExtraController,
            label: 'Past Record Extra',
            icon: Icons.note_add,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _personalRecordController,
            label: 'Personal Record',
            icon: Icons.fact_check,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _employmentHistoryController,
            label: 'Employment History',
            icon: Icons.work_history,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _refereesController,
            label: 'Referees',
            icon: Icons.people_outline,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _extraNoteController,
            label: 'Extra Note',
            icon: Icons.sticky_note_2,
          ),
          const SizedBox(height: 12),

          // Next of Kin
          _buildTextField(
            controller: _nextOfKinNameController,
            label: 'Next of Kin Name',
            icon: Icons.person_2,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _nextOfKinAddressController,
            label: 'Next of Kin Address',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _nextOfKinEmailController,
                  label: 'Next of Kin Email',
                  icon: Icons.alternate_email,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _nextOfKinPhoneController,
                  label: 'Next of Kin Phone',
                  icon: Icons.phone_android,
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Employment date
          GestureDetector(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: now,
                firstDate: DateTime(1970),
                lastDate: DateTime(now.year + 1),
              );
              if (picked != null) {
                _employmentDateController.text = picked.toIso8601String().substring(0, 10);
                setState(() {});
              }
            },
            child: AbsorbPointer(
              child: _buildTextField(
                controller: _employmentDateController,
                label: 'Employment Date (YYYY-MM-DD)',
                icon: Icons.event,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Employment status
          _buildDropdown(
            label: 'Employment Status',
            value: _selectedStatus,
            items: ['Active', 'Inactive', 'Suspended'],
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
            },
          ),
          const SizedBox(height: 12),

          // Appraisals
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _healthAppraisalController,
                  label: 'Health Appraisal',
                  icon: Icons.monitor_heart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _generalAppraisalController,
                  label: 'General Appraisal',
                  icon: Icons.star_rate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Department & Grade
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _departmentController,
                  label: 'Department',
                  icon: Icons.apartment,
                  keyboardType: TextInputType.number
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _gradeController,
                  label: 'Grade (number)',
                  icon: Icons.format_list_numbered,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Section & Designation (IDs as numbers)
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _sectionController,
                  label: 'Section (ID number)',
                  icon: Icons.grid_view,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _designationController,
                  label: 'Designation (ID number)',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.text2Light,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                _isEditing ? 'Update Staff' : 'Add Staff',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Urbanist',
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
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.text7Light),
        labelStyle: const TextStyle(
          color: AppColors.text5Light,
          fontSize: 14,
          fontFamily: 'Urbanist',
        ),
        filled: true,
        fillColor: AppColors.textFieldLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.textFieldBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.textFieldBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.text2Light, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.text5Light,
          fontSize: 14,
          fontFamily: 'Urbanist',
        ),
        filled: true,
        fillColor: AppColors.textFieldLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.textFieldBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.textFieldBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.text2Light, width: 2),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _salaryController.clear();
    _surnameController.clear();
    _firstNameController.clear();
    _middleNameController.clear();
    _birthDateController.clear();
    _cityController.clear();
    _stateController.clear();
    _countryController.clear();
    _religionController.clear();
    _lgaOriginController.clear();
    _stateOriginController.clear();
    _nationalityController.clear();
    _homeTownController.clear();
    _healthStatusController.clear();
    _pastRecordController.clear();
    _pastRecordExtraController.clear();
    _personalRecordController.clear();
    _employmentHistoryController.clear();
    _refereesController.clear();
    _extraNoteController.clear();
    _nextOfKinNameController.clear();
    _nextOfKinAddressController.clear();
    _nextOfKinEmailController.clear();
    _nextOfKinPhoneController.clear();
    _employmentDateController.clear();
    _healthAppraisalController.clear();
    _generalAppraisalController.clear();
    _gradeController.clear();
    _departmentController.clear();
    _sectionController.clear();
    _designationController.clear();
    _selectedGender = 'Male';
    _selectedRole = 'Teacher';
    _selectedStatus = 'Active';
    _selectedMaritalStatus = 'single';
    _selectedAccessLevel = 'staff';
    _selectedCourses.clear();
  }

void _handleSubmit() async {
  // Basic validation
  if (_surnameController.text.trim().isEmpty ||
      _firstNameController.text.trim().isEmpty ||
      _emailController.text.trim().isEmpty ||
      _phoneController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please fill in all required fields (Surname, First Name, Email, Phone)'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final newStaff = {
    'surname': _surnameController.text.trim(),
    'first_name': _firstNameController.text.trim(),
    'middle_name': _middleNameController.text.trim(),
    'gender': _selectedGender.toLowerCase(),
    'email': _emailController.text.trim(),
    'phone': _phoneController.text.trim(),
    'birth_date': _birthDateController.text.trim(),
    'address': _addressController.text.trim(),
    'city': _cityController.text.trim(),
    'state': _stateController.text.trim(),
    'country': _countryController.text.trim(),
    'phone_number': _phoneController.text.trim(),
    'religion': _religionController.text.trim(),
    'marital_status': _selectedMaritalStatus,
    'lga_origin': _lgaOriginController.text.trim(),
    'state_origin': _stateOriginController.text.trim(),
    'nationality': _nationalityController.text.trim(),
    'home_town': _homeTownController.text.trim(),
    'health_status': _healthStatusController.text.trim(),
    'past_record': _pastRecordController.text.trim(),
    'past_record_extra': _pastRecordExtraController.text.trim(),
    'personal_record': _personalRecordController.text.trim(),
    'employment_history': _employmentHistoryController.text.trim(),
    'referees': _refereesController.text.trim(),
    'extra_note': _extraNoteController.text.trim(),
    'next_of_kin_name': _nextOfKinNameController.text.trim(),
    'next_of_kin_address': _nextOfKinAddressController.text.trim(),
    'next_of_kin_email': _nextOfKinEmailController.text.trim(),
    'next_of_kin_phone': _nextOfKinPhoneController.text.trim(),
    'employment_date': _employmentDateController.text.trim(),
    'employment_status': _selectedStatus,
    'health_appraisal': _healthAppraisalController.text.trim(),
    'general_appraisal': _generalAppraisalController.text.trim(),
    'grade': int.tryParse(_gradeController.text.trim()),
    'department': _departmentController.text.trim(),
    'section': int.tryParse(_sectionController.text.trim()),
    'designation': int.tryParse(_designationController.text.trim()),
    'access_level': _selectedAccessLevel,
  };

  print("Creating Staff: $newStaff");

  // Get the provider
  final addStaffProvider = Provider.of<AddStaffProvider>(context, listen: false);
  bool success;

 if (_isEditing) {
 

    success = await addStaffProvider.updateStaff(_editingStaffId!, newStaff);
  } else {
    success = await addStaffProvider.createStaff(newStaff);
  }

  if (success) {
    // Fetch fresh staff data to refresh the screen
    await addStaffProvider.fetchAllStaff();
    
    // Clear the form
    _clearForm();
    
    // Hide the form
    setState(() {
      _showAddForm = false;
      _isEditing = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(addStaffProvider.message ?? 'Staff created successfully!'),
        backgroundColor: AppColors.attCheckColor2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  } else {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(addStaffProvider.error ?? 'Failed to create staff'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}





void _editStaff(int index) {
  final provider = Provider.of<AddStaffProvider>(context, listen: false);
  final filteredList = _filteredStaffList;
  final staffMap = filteredList[index];

  // Find the actual staff object in provider.staffList using the staffNo (mapped as 'id' in toDisplayMap)
  final staff = provider.staffList.firstWhere(
    (s) => s.staffNo == staffMap['id'],
    orElse: () => throw Exception('Staff not found'),
  );

  setState(() {
    _isEditing = true;
    _showAddForm = true;
  _editingStaffId = staff.staffNo;
    // Populate form fields with data from the Staff object
    _surnameController.text = staff.lastName ?? '';
    _firstNameController.text = staff.firstName ?? '';
    _middleNameController.text = staff.middleName ?? '';
    _emailController.text = staff.emailAddress ?? '';
    _phoneController.text = staff.phoneNumber ?? '';
    _addressController.text = staff.address ?? '';
    _birthDateController.text = staff.birthDate ?? '';
    _cityController.text = staff.city ?? '';
    _stateController.text = staff.state?.toString() ?? '';
    _countryController.text = staff.country ?? '';
    _religionController.text = staff.religion ?? '';
    _lgaOriginController.text = staff.lgaOrigin ?? '';
    _stateOriginController.text = staff.stateOrigin ?? '';
    _nationalityController.text = staff.nationality ?? '';
    _homeTownController.text = staff.homeTown ?? '';
    _healthStatusController.text = staff.healthStatus ?? '';
    _pastRecordController.text = staff.pastRecord ?? '';
    _pastRecordExtraController.text = staff.pastRecordExtra ?? '';
    _personalRecordController.text = staff.personalRecord ?? '';
    _employmentHistoryController.text = staff.employmentHistory ?? '';
    _refereesController.text = staff.referees ?? '';
    _extraNoteController.text = staff.extraNote ?? '';
    _nextOfKinNameController.text = staff.nextOfKinName ?? '';
    _nextOfKinAddressController.text = staff.nextOfKinAddress ?? '';
    _nextOfKinEmailController.text = staff.nextOfKinEmail ?? '';
    _nextOfKinPhoneController.text = staff.nextOfKinPhone ?? '';
    _employmentDateController.text = staff.employmentDate ?? '';
    _healthAppraisalController.text = staff.healthAppraisal ?? '';
    _generalAppraisalController.text = staff.generalAppraisal ?? '';
    _gradeController.text = staff.grade?.toString() ?? '';
    _departmentController.text = staff.department?.toString() ?? '';
    _sectionController.text = staff.section?.toString() ?? '';
    _designationController.text = staff.designation?.toString() ?? '';

    // Populate dropdowns and other state variables
   _selectedGender = (staff.gender?.toLowerCase() == 'male')
        ? 'Male'
        : (staff.gender?.toLowerCase() == 'female' ? 'Female' : 'Male');
    _selectedRole = staff.accessLevel == 'admin' ? 'Admin Staff' : 'Teacher';
    _selectedStatus = staff.employmentStatus ?? 'Active';
    _selectedMaritalStatus = staff.maritalStatus ?? 'single';
    _selectedAccessLevel = staff.accessLevel ?? 'staff';
    _selectedCourses = staffMap['courses'] ?? <String>[]; // Use courses from toDisplayMap or fetch separately if available
  });
}

  void _deleteStaff(int index) async {

  final provider = Provider.of<AddStaffProvider>(context, listen: false);
  final staff = provider.staffList[index];
      print('Are you sure you want to delete ${staff.fullName}?');
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Staff'),
      content: Text('Are you sure you want to delete ${staff.fullName}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            
            final success = await provider.deleteStaff(staff.id);
            
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Staff deleted successfully!'),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.error ?? 'Failed to delete staff'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

  void _showAssignCourseDialog(int index) {
    final provider = Provider.of<AddStaffProvider>(context, listen: false);
    final filteredList = _filteredStaffList;
    final staffMap = filteredList[index];
    
    // Find the actual staff object in provider's list
    final staff = provider.staffList.firstWhere((s) => s.id.toString() == staffMap['id']);
    List<String> tempSelectedCourses = <String>[]; // Staff model doesn't have courses field yet
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Assign Courses'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableCourses.length,
              itemBuilder: (context, courseIndex) {
                final course = _availableCourses[courseIndex];
                final isSelected = tempSelectedCourses.contains(course);
                
                return CheckboxListTile(
                  title: Text(course),
                  value: isSelected,
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        tempSelectedCourses.add(course);
                      } else {
                        tempSelectedCourses.remove(course);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                // Update the staff with new courses via API
                final updatedStaff = staff.toJson();
                updatedStaff['courses'] = tempSelectedCourses;
                
                final success = await provider.updateStaff(_editingStaffId!, updatedStaff);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Courses assigned successfully!'),
                      backgroundColor: AppColors.attCheckColor2,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.error ?? 'Failed to assign courses'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignClassDialog(int index) {
    final provider = Provider.of<AddStaffProvider>(context, listen: false);
    final filteredList = _filteredStaffList;
    final staffMap = filteredList[index];
    
    // Find the actual staff object in provider's list
    final staff = provider.staffList.firstWhere((s) => s.id.toString() == staffMap['id']);
    String tempLevel = _availableLevels.first; // Staff model doesn't have level field yet
    String tempClass = ''; // Staff model doesn't have class field yet
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Assign Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: tempLevel,
                decoration: const InputDecoration(
                  labelText: 'Select Level',
                ),
                items: _availableLevels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    tempLevel = value!;
                    tempClass = ''; // Reset class when level changes
                  });
                },
              ),
              const SizedBox(height: 16),
              if (tempLevel.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: tempClass.isEmpty ? null : tempClass,
                  decoration: const InputDecoration(
                    labelText: 'Select Class',
                  ),
                  items: _classesPerLevel[tempLevel]?.map((className) {
                    return DropdownMenuItem(
                      value: className,
                      child: Text(className),
                    );
                  }).toList() ?? [],
                  onChanged: (value) {
                    setDialogState(() {
                      tempClass = value ?? '';
                    });
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (tempClass.isNotEmpty) {
                  Navigator.pop(context);
                  
                  // Update the staff with new level and class via API
                  final updatedStaff = staff.toJson();
                  updatedStaff['level'] = tempLevel;
                  updatedStaff['class'] = tempClass;
                  
                  final success = await provider.updateStaff(_editingStaffId!, updatedStaff);
                  
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Class assigned successfully!'),
                        backgroundColor: AppColors.attCheckColor2,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.error ?? 'Failed to assign class'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select both level and class'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },

             
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddStaffProvider>(
      builder: (context, provider, child) {
        final filteredStaff = _filteredStaffList;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Staff',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.text2Light,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showAddForm = !_showAddForm;
                if (_showAddForm) {
                  _clearForm();
                  _isEditing = false;
                }
              });
            },
            icon: Icon(_showAddForm ? Icons.close : Icons.add),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: Constants.customBoxDecoration(context),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Section
              _buildAnimatedCard(
                index: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.text2Light.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.people,
                              color: AppColors.text2Light,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Staff Overview',
                            style: AppTextStyles.normal600(
                              fontSize: 20,
                              color: AppColors.text2Light,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatsCard(
                              title: 'Total Staff',
                              value:  provider.staffList.length.toString(),
                              icon: Icons.group,
                              iconColor: AppColors.text2Light,
                              backgroundColor: AppColors.boxColor1,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatsCard(
                              title: 'Active Staff',
                              value: provider.staffList.where((s) => s.isActive).length.toString(),
                              icon: Icons.check_circle,
                              iconColor: AppColors.attCheckColor2,
                              backgroundColor: AppColors.boxColor2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatsCard(
                              title: 'Teachers',
                              value: provider.staffList.where((s) => s.accessLevel != 'admin').length.toString(),
                              icon: Icons.school,
                              iconColor: AppColors.secondaryLight,
                              backgroundColor: AppColors.boxColor3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Add Staff Form (conditionally shown)
              if (_showAddForm)
                _buildAnimatedCard(
                  index: 1,
                  child: _buildAddStaffForm(),
                ),

              if (_showAddForm) const SizedBox(height: 16),

              // Search and Filter Section
              _buildAnimatedCard(
                index: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search staff by name, email, or ID...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.text7Light),
                          suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.clear, color: AppColors.text7Light),
                              )
                            : null,
                          hintStyle: const TextStyle(
                            color: AppColors.text5Light,
                            fontSize: 14,
                            fontFamily: 'Urbanist',
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(color: AppColors.textFieldBorderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(color: AppColors.textFieldBorderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(color: AppColors.text2Light, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', _selectedFilter == 'All'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Teacher', _selectedFilter == 'Teacher'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Principal', _selectedFilter == 'Principal'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Vice Principal', _selectedFilter == 'Vice Principal'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Admin Staff', _selectedFilter == 'Admin Staff'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Staff List Section
              _buildAnimatedCard(
                index: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Staff Members (${filteredStaff.length})',
                            style: AppTextStyles.normal600(
                              fontSize: 18,
                              color: AppColors.text2Light,
                            ),
                          ),
                          if (filteredStaff.length != _staffList.length)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedFilter = 'All';
                                  _searchController.clear();
                                });
                              },
                              child: const Text(
                                'Clear filters',
                                style: TextStyle(
                                  color: AppColors.text2Light,
                                  fontFamily: 'Urbanist',
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (filteredStaff.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: AppColors.text7Light,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No staff members found',
                                  style: AppTextStyles.normal500(
                                    fontSize: 16,
                                    color: AppColors.text7Light,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchController.text.isNotEmpty 
                                    ? 'Try adjusting your search criteria'
                                    : 'Add staff members to get started',
                                  style: AppTextStyles.normal400(
                                    fontSize: 14,
                                    color: AppColors.text9Light,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredStaff.length,
                          itemBuilder: (context, index) {
                            return TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: Duration(milliseconds: 300 + (index * 100)),
                              curve: Curves.easeOutBack,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: _buildStaffCard(filteredStaff[index], index),
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 100), // Bottom padding for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: !_showAddForm 
        ? FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                _showAddForm = true;
                _clearForm();
                _isEditing = false;
              });
            },
            icon: const Icon(Icons.add),
            label: const Text(
              'Add Staff',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.text2Light,
            foregroundColor: Colors.white,
          )
        : null,
    );
      },
    );
  }
}