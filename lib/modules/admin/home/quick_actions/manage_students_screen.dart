import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkschool/modules/admin/home/quick_actions/student_details.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/admin/home/level_class_model.dart';
import 'package:linkschool/modules/model/admin/home/manage_student_model.dart';
import 'package:linkschool/modules/providers/admin/home/level_class_provider.dart';
import 'package:linkschool/modules/providers/admin/home/manage_student_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  int? selectedLevelId;
  int? selectedClassId;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ManageStudentProvider>(context, listen: false).fetchStudents();
      Provider.of<LevelClassProvider>(context, listen: false).fetchLevels();
    });
  }

  List<Students> get filteredStudents {
    final provider = Provider.of<ManageStudentProvider>(context);
    return provider.students.where((student) {
      bool levelMatch = selectedLevelId == null || student.levelId == selectedLevelId;
      bool classMatch = selectedClassId == null || student.classId == selectedClassId;
      return levelMatch && classMatch;
    }).toList();
  }

  

  bool _showAddForm = false;
  Students? _editingStudent;

  void _showAddEditStudentForm({Students? student}) {
    setState(() {
      _showAddForm = true;
      _editingStudent = student;
    });
  }

  void _hideForm() {
    setState(() {
      _showAddForm = false;
      _editingStudent = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<ManageStudentProvider>(context);
    final levelClassProvider = Provider.of<LevelClassProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
        backgroundColor: AppColors.text2Light,
        foregroundColor: Colors.white,
        actions: [
          if (_showAddForm)
            IconButton(
              onPressed: _hideForm,
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: studentProvider.isLoading || levelClassProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: Constants.customBoxDecoration(context),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_showAddForm)
                      StudentFormWidget(
                        student: _editingStudent,
                        onCancel: _hideForm,
                        onSaved: _hideForm,
                      )
                    else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: selectedLevelId,
                                decoration: const InputDecoration(
                                  labelText: 'Filter by Level',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('All Levels'),
                                  ),
                                  ...levelClassProvider.levelsWithClasses.map((levelWithClasses) {
                                    return DropdownMenuItem(
                                      value: levelWithClasses.level.id,
                                      child: Text(levelWithClasses.level.levelName),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedLevelId = value;
                                    selectedClassId = null;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: (selectedClassId != null && selectedLevelId != null && levelClassProvider.levelsWithClasses.any((lwc) => lwc.level.id == selectedLevelId && lwc.classes.any((c) => c.id == selectedClassId)))
                                    ? selectedClassId
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: 'Filter by Class',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('All Classes'),
                                  ),
                                  if (selectedLevelId != null)
                                    ...levelClassProvider.levelsWithClasses
                                        .firstWhere((lwc) => lwc.level.id == selectedLevelId)
                                        .classes
                                        .map((cls) => DropdownMenuItem(
                                              value: cls.id,
                                              child: Text(cls.className),
                                            )),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedClassId = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      filteredStudents.isEmpty
                          ? const Center(child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text('No students found'),
                            ))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = filteredStudents[index];
                                final levelName = levelClassProvider.levelsWithClasses
                                    .firstWhere(
                                      (lwc) => lwc.level.id == student.levelId,
                                      orElse: () => LevelWithClasses(
                                        level: Levels(
                                          id: 0,
                                          levelName: 'Unknown',
                                          schoolType: '',
                                          rank: 0,
                                          admit: 0,
                                        ),
                                        classes: [],
                                      ),
                                    )
                                    .level
                                    .levelName;
                                final className = levelClassProvider.levelsWithClasses
                                    .firstWhere(
                                      (lwc) => lwc.level.id == student.levelId,
                                      orElse: () => LevelWithClasses(
                                        level: Levels(
                                          id: 0,
                                          levelName: 'Unknown',
                                          schoolType: '',
                                          rank: 0,
                                          admit: 0,
                                        ),
                                        classes: [],
                                      ),
                                    )
                                    .classes
                                    .firstWhere(
                                      (cls) => cls.id == student.classId,
                                      orElse: () => Class(
                                        id: 0,
                                        className: 'Unknown',
                                        levelId: 0,
                                        formTeacherIds: [],
                                      ),
                                    )
                                    .className;

                                return GestureDetector(
                                  onTap: () {
                                    final fullName = '${student.firstName} ${student.surname}';
                                    print(fullName);
                                    print(student.levelId );
                                    print(className);
                                    print(student.classId);
                                 

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => StudentProfileScreen(
        student: student,
        classId:student.classId.toString(),
        levelId: student.levelId,
        className: className,
        studentName: fullName,
      ),
    ),
  );
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.text2Light,
                                        child: student.photoPath != null && student.photoPath!.isNotEmpty
                                            ? ClipOval(
                                                child: Image.network(
                                                  "https://linkskool.net/${student.photoPath}",
                                                  fit: BoxFit.cover,
                                                  width: 40,
                                                  height: 40,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Text(
                                                      student.getInitials(),
                                                      style: const TextStyle(color: Colors.white),
                                                    );
                                                  },
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return const CircularProgressIndicator(strokeWidth: 2);
                                                  },
                                                ),
                                              )
                                            : Text(
                                                student.getInitials(),
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                      ),
                                      title: Text('${student.firstName} ${student.surname}'),
                                      subtitle: Text('$levelName - $className | ID: ${student.registrationNo ?? student.id}'),
                                      trailing: PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _showAddEditStudentForm(student: student);
                                          } else if (value == 'delete') {
                                            _showDeleteDialog(context, student);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: ListTile(
                                              leading: Icon(Icons.edit),
                                              title: Text('Edit'),
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: ListTile(
                                              leading: Icon(Icons.delete, color: Colors.red),
                                              title: Text('Delete', style: TextStyle(color: Colors.red)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ],
                ),
              ),
            ),
      floatingActionButton: !_showAddForm
          ? FloatingActionButton.extended(
              onPressed: _showAddEditStudentForm,
              backgroundColor: AppColors.text2Light,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Student',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  void _showDeleteDialog(BuildContext context, Students student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.firstName} ${student.surname}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<ManageStudentProvider>(
            builder: (context, provider, _) => ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      final success = await provider.deleteStudent(student.id.toString());
                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Student deleted successfully')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(provider.error ?? 'Failed to delete student'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: provider.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Delete'),
            ),
          ),
        ],
      ),
    );
  }
}

// Separate StatefulWidget for the form to isolate state management
class StudentFormWidget extends StatefulWidget {
  final Students? student;
  final VoidCallback onCancel;
  final VoidCallback onSaved;

  const StudentFormWidget({
    super.key,
    this.student,
    required this.onCancel,
    required this.onSaved,
  });

  @override
  State<StudentFormWidget> createState() => _StudentFormWidgetState();
}

class _StudentFormWidgetState extends State<StudentFormWidget> {
late final TextEditingController _fullNameController;
  late final TextEditingController middleNameController;
  late final TextEditingController birthDateController;
  late final TextEditingController addressController;
  late final TextEditingController cityController;
  late final TextEditingController stateController;
  late final TextEditingController countryController;
  late final TextEditingController emailController;
  late final TextEditingController religionController;
  late final TextEditingController guardianNameController;
  late final TextEditingController guardianAddressController;
  late final TextEditingController guardianPhoneController;
  late final TextEditingController lgaOriginController;
  late final TextEditingController stateOriginController;
  late final TextEditingController nationalityController;
  late final TextEditingController healthStatusController;
  late final TextEditingController studentStatusController;
  late final TextEditingController pastRecordController;
  late final TextEditingController academicResultController;
  late final TextEditingController registrationNoController;

  String? gender;
  int? dialogLevelId;
  int? dialogClassId;
  File? tempImage;
  String oldFileName = '';

  bool get isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    
    final student = widget.student;
    
    final fullName = '${student?.surname ?? ''} ${student?.firstName ?? ''}'.trim();
    _fullNameController = TextEditingController(text: fullName);

    middleNameController = TextEditingController(text: student?.middle ?? '');
    birthDateController = TextEditingController(text: student?.birthDate ?? '');
    addressController = TextEditingController(text: student?.address ?? '');
    cityController = TextEditingController(text: student?.city?.toString() ?? '');
    stateController = TextEditingController(text: student?.state?.toString() ?? '');
    countryController = TextEditingController(text: student?.country?.toString() ?? '');
    emailController = TextEditingController(text: student?.email ?? '');
    religionController = TextEditingController(text: student?.religion ?? '');
    guardianNameController = TextEditingController(text: student?.guardianName ?? '');
    guardianAddressController = TextEditingController(text: student?.guardianAddress ?? '');
    guardianPhoneController = TextEditingController(text: student?.guardianPhoneNo ?? '');
    lgaOriginController = TextEditingController(text: student?.lgaOrigin ?? '');
    stateOriginController = TextEditingController(text: student?.stateOrigin ?? '');
    nationalityController = TextEditingController(text: student?.nationality ?? '');
    healthStatusController = TextEditingController(text: student?.healthStatus ?? '');
    studentStatusController = TextEditingController(text: student?.studentStatus ?? '');
    pastRecordController = TextEditingController(text: student?.pastRecord ?? '');
    academicResultController = TextEditingController(text: student?.academicResult ?? '');
    registrationNoController = TextEditingController(text: student?.registrationNo ?? '');

    gender = student?.gender.isNotEmpty == true
        ? (student!.gender.toLowerCase() == 'f' ? 'female' : 'male')
        : 'male';

    dialogLevelId = student?.levelId;
    dialogClassId = student?.classId;

    if (isEditing && student?.photo != null && (student!.photo is String) && (student.photo as String).isNotEmpty) {
      oldFileName = path.basename(student.photo as String);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    middleNameController.dispose();
    birthDateController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    emailController.dispose();
    religionController.dispose();
    guardianNameController.dispose();
    guardianAddressController.dispose();
    guardianPhoneController.dispose();
    lgaOriginController.dispose();
    stateOriginController.dispose();
    nationalityController.dispose();
    healthStatusController.dispose();
    studentStatusController.dispose();
    pastRecordController.dispose();
    academicResultController.dispose();
    registrationNoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => tempImage = File(pickedFile.path));
    }
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

Future<void> _saveStudent() async {
  final fullName = _fullNameController.text.trim();
  
  // Validate full name first
  if (fullName.isEmpty) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter full name'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }

  // Parse name
  final nameParts = fullName.split(' ').where((part) => part.isNotEmpty).toList();
  String surname = '';
  String firstName = '';

  if (nameParts.length < 2) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both surname and first name (e.g., Smith John)'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }

  surname = nameParts[0]; // First part is surname
  firstName = nameParts.sublist(1).join(' '); // Rest is first name

  // Validate gender
  if (gender == null) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Gender'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }

  // Validate birth date
  if (birthDateController.text.trim().isEmpty) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Birth Date'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }

  final studentProvider = Provider.of<ManageStudentProvider>(context, listen: false);

  // Handle photo upload
  String? base64Image;
  String? newFileName;
  
  if (tempImage != null) {
    final bytes = await tempImage!.readAsBytes();
    base64Image = base64Encode(bytes);
    newFileName = path.basename(tempImage!.path);
  }

  // Build student data
  final studentData = <String, dynamic>{
    'surname': surname,
    'first_name': firstName,
    'middle': middleNameController.text.trim(),
    'gender': gender,
    'birth_date': birthDateController.text.trim(),
    'address': addressController.text.trim(),
    'city': int.tryParse(cityController.text) ?? 0,
    'state': int.tryParse(stateController.text) ?? 0,
    'country': int.tryParse(countryController.text) ?? 0,
    'email': emailController.text.trim(),
    'religion': religionController.text.trim(),
    'guardian_name': guardianNameController.text.trim(),
    'guardian_address': guardianAddressController.text.trim(),
    'guardian_phone_no': guardianPhoneController.text.trim(),
    'lga_origin': lgaOriginController.text.trim(),
    'state_origin': stateOriginController.text.trim(),
    'nationality': nationalityController.text.trim(),
    'health_status': healthStatusController.text.trim(),
    'student_status': studentStatusController.text.trim(),
    'past_record': pastRecordController.text.trim(),
    'academic_result': academicResultController.text.trim(),
    'level_id': dialogLevelId,
    'class_id': dialogClassId,
    'registration_no': registrationNoController.text.trim(),
  };

  // CRITICAL FIX: Always send photo as an object/map structure
  if (tempImage != null && base64Image != null) {
    // New image selected - send with base64
    studentData['photo'] = {
      "file": base64Image,
      "file_name": newFileName,
      "old_file_name": oldFileName.isNotEmpty ? oldFileName : "",
    };
  } else if (isEditing) {
    // Editing without new image - send existing path in proper structure
    studentData['photo'] = {
      "file": widget.student?.photoPath ?? "",
      "file_name": oldFileName.isNotEmpty ? oldFileName : "",
      "old_file_name": "",
    };
  } else {
    // Creating new student without photo - send empty structure
    studentData['photo'] = {
      "file": "",
      "file_name": "",
      "old_file_name": "",
    };
  }

  bool success;
  if (isEditing) {
    success = await studentProvider.updateStudent(
      widget.student!.id.toString(), 
      studentData
    );
  } else {
    success = await studentProvider.createStudent(studentData);
  }

  // Check if widget is still mounted before showing snackbar
  if (!mounted) return;

  if (success) {
    widget.onSaved();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing ? 'Student updated successfully' : 'Student added successfully'
        ),
        backgroundColor: AppColors.attCheckColor2,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(studentProvider.error ?? 'Failed to save student'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<ManageStudentProvider>(context);
    
    return Container(
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
              // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Student' : 'Add New Student',
                  style: AppTextStyles.normal600(
                    fontSize: 18,
                    color: AppColors.text2Light,
                  ),
                ),
                IconButton(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.close, color: AppColors.text5Light),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Image picker
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.textFieldLight,
                  backgroundImage: tempImage != null
                      ? FileImage(tempImage!)
                      : (widget.student?.photoPath != null && widget.student!.photoPath!.isNotEmpty)
                          ? NetworkImage("https://linkskool.net/${widget.student!.photoPath}") as ImageProvider<Object>
                          : null,
                  child: tempImage == null && (widget.student?.photoPath == null || widget.student!.photoPath!.isEmpty)
                      ? const Icon(Icons.add_a_photo, color: AppColors.text2Light, size: 40)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Form fields
           _buildTextField(
  controller: _fullNameController,
  label: 'Full Name * (Surname First)',
  icon: Icons.person,
  hintText: 'e.g., Smith John David',
),
const SizedBox(height: 12),
            const SizedBox(height: 12),
            _buildTextField(controller: middleNameController, label: 'Middle Name', icon: Icons.person_outline),
            const SizedBox(height: 12),

            _buildDropdown(
              label: 'Gender',
              value: gender,
              items: ['male', 'female']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g.capitalize())))
                  .toList(),
              onChanged: (val) => setState(() => gender = val),
            ),

            const SizedBox(height: 12),
            GestureDetector(
              onTap: _selectBirthDate,
              child: AbsorbPointer(
                child: _buildTextField(
                  controller: birthDateController,
                  label: 'Birth Date',
                  icon: Icons.cake,
                  readOnly: true,
                ),
              ),
            ),

            const SizedBox(height: 12),
            _buildTextField(controller: addressController, label: 'Address', icon: Icons.location_on),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField(controller: cityController, label: 'City ID', icon: Icons.location_city, keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(controller: stateController, label: 'State ID', icon: Icons.map, keyboardType: TextInputType.number)),
              ],
            ),

            const SizedBox(height: 12),
            _buildTextField(controller: countryController, label: 'Country ID', icon: Icons.flag, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField(controller: emailController, label: 'Email', icon: Icons.email, keyboardType: TextInputType.emailAddress),

            const SizedBox(height: 12),
            _buildTextField(controller: religionController, label: 'Religion', icon: Icons.church),
            const SizedBox(height: 12),
            _buildTextField(controller: guardianNameController, label: 'Guardian Name', icon: Icons.person),
            const SizedBox(height: 12),
            _buildTextField(controller: guardianAddressController, label: 'Guardian Address', icon: Icons.home),
            const SizedBox(height: 12),
            _buildTextField(controller: guardianPhoneController, label: 'Guardian Phone', icon: Icons.phone_android, keyboardType: TextInputType.phone),

            const SizedBox(height: 12),
            Consumer<LevelClassProvider>(
              builder: (context, provider, _) => _buildDropdown(
                label: 'Level',
                value: dialogLevelId,
                items: provider.levelsWithClasses
                    .map((lvl) => DropdownMenuItem(
                          value: lvl.level.id,
                          child: Text(lvl.level.levelName),
                        ))
                    .toList(),
                onChanged: (value) => setState(() {
                  dialogLevelId = value;
                  dialogClassId = null;
                }),
              ),
            ),

            const SizedBox(height: 12),
            Consumer<LevelClassProvider>(
              builder: (context, provider, _) => _buildDropdown(
                label: 'Class',
                value: dialogClassId,
                items: dialogLevelId == null
                    ? []
                    : provider.levelsWithClasses
                        .firstWhere((lvl) => lvl.level.id == dialogLevelId)
                        .classes
                        .map((cls) => DropdownMenuItem(value: cls.id, child: Text(cls.className)))
                        .toList(),
                onChanged: (value) => setState(() => dialogClassId = value),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: studentProvider.isLoading ? null : _saveStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.text2Light,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: studentProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEditing ? 'Update Student' : 'Add Student',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
      String? hintText, 
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.text2Light),
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
    required dynamic value,
    required List<DropdownMenuItem<dynamic>> items,
    required Function(dynamic) onChanged,
  }) {
    return DropdownButtonFormField<dynamic>(
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
      items: items,
      onChanged: onChanged,
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}