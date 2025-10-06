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

 void _showAddEditStudentForm({Students? student}) {
    final studentProvider = Provider.of<ManageStudentProvider>(context, listen: false);
    final levelClassProvider = Provider.of<LevelClassProvider>(context, listen: false);
    final isEditing = student != null;
    final surnameController = TextEditingController(text: student?.surname ?? '');
    final firstNameController = TextEditingController(text: student?.firstName ?? '');
    final middleNameController = TextEditingController(text: student?.middle ?? '');
   String? gender = student?.gender.isNotEmpty == true 
    ? (student!.gender == 'f' || student!.gender == 'F' ? 'female' : 
       student.gender == 'm' || student.gender == 'M' ? 'male' : student.gender)
    : 'male';
    final birthDateController = TextEditingController(text: student?.birthDate ?? '');
    final addressController = TextEditingController(text: student?.address ?? '');
    final cityController = TextEditingController(text: student?.city?.toString() ?? '');
    final stateController = TextEditingController(text: student?.state?.toString() ?? '');
    final countryController = TextEditingController(text: student?.country?.toString() ?? '');
    final emailController = TextEditingController(text: student?.email ?? '');
    final religionController = TextEditingController(text: student?.religion ?? '');
    final guardianNameController = TextEditingController(text: student?.guardianName ?? '');
    final guardianAddressController = TextEditingController(text: student?.guardianAddress ?? '');
    
    final guardianPhoneController = TextEditingController(text: student?.guardianPhoneNo ?? '');
    final lgaOriginController = TextEditingController(text: student?.lgaOrigin ?? '');
    final stateOriginController = TextEditingController(text: student?.stateOrigin ?? '');
    final nationalityController = TextEditingController(text: student?.nationality ?? '');
    final healthStatusController = TextEditingController(text: student?.healthStatus ?? '');
    final dateAdmittedController = TextEditingController(text: student?.dateAdmitted ?? '');
    final studentStatusController = TextEditingController(text: student?.studentStatus ?? '');
    final pastRecordController = TextEditingController(text: student?.pastRecord ?? '');
    final academicResultController = TextEditingController(text: student?.academicResult ?? '');
    final registrationNoController = TextEditingController(text: student?.registrationNo ?? '');
    int? dialogLevelId = student?.levelId;
    int? dialogClassId = student?.classId;
    File? tempImage;
     String oldFileName = '';
print("student photo:sss ${student?.photo}");
  if (isEditing && student?.photo != null && student!.photo is String && (student.photo as String).isNotEmpty) {
    // Extract the filename from the returned photo path
    print("student photo:sss ${student?.photo}");
    oldFileName = path.basename(student.photo as String); 
  }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
       builder: (context, setState) => Padding(
  padding: const EdgeInsets.all(8.0),
  child: Dialog(
    insetPadding: EdgeInsets.zero, // Remove default Dialog padding
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: MediaQuery.of(context).size.width, // Full width
      curve: Curves.easeInOut,
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(10.0),
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.text5Light,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setState(() {
                              tempImage = File(pickedFile.path);
                            });
                          }
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.text2Light, width: 2),
                            color: AppColors.textFieldLight,
                          ),
                          child: tempImage != null
    ? ClipOval(child: Image.file(tempImage!, fit: BoxFit.cover))
    : student?.photo?.file != null
        ? ClipOval(
            child: Image.memory(
              base64Decode(student!.photo!.file!),
              fit: BoxFit.cover,
            ),
          )
        : (student?.photoPath != null && student!.photoPath!.isNotEmpty)
            ? ClipOval(
                child: Image.network(
                  "https://linkskool.net/${student.photoPath}",
                  fit: BoxFit.cover,
                ),
              )
                                  : Icon(Icons.add_a_photo, color: AppColors.text2Light, size: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: surnameController,
                            label: 'Surname',
                            icon: Icons.badge,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: firstNameController,
                            label: 'First Name',
                            icon: Icons.person,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: middleNameController,
                      label: 'Middle Name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Gender',
                      value: gender,
                     items: ['male', 'female'].map((g) => DropdownMenuItem(
  value: g,
  child: Text(g.capitalize()),
)).toList(),

                      onChanged: (value) {
                        setState(() {
                          gender = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: DateTime(1900),
                          lastDate: now,
                        );
                        if (picked != null) {
                          setState(() {
                            birthDateController.text =
                                "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: _buildTextField(
                          controller: birthDateController,
                          label: 'Birth Date (YYYY-MM-DD)',
                          icon: Icons.cake,
                          readOnly: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: addressController,
                      label: 'Address',
                      icon: Icons.location_on,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: cityController,
                            label: 'City ID',
                            icon: Icons.location_city,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: stateController,
                            label: 'State ID',
                            icon: Icons.map,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: countryController,
                      label: 'Country ID',
                      icon: Icons.flag,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: religionController,
                      label: 'Religion',
                      icon: Icons.church,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: guardianNameController,
                      label: 'Guardian Name',
                      icon: Icons.person_2,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: guardianAddressController,
                      label: 'Guardian Address',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                       
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: guardianPhoneController,
                            label: 'Guardian Phone',
                            icon: Icons.phone_android,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: lgaOriginController,
                            label: 'LGA Origin',
                            icon: Icons.place,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: stateOriginController,
                            label: 'State Origin',
                            icon: Icons.public,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: nationalityController,
                      label: 'Nationality',
                      icon: Icons.language,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: healthStatusController,
                      label: 'Health Status',
                      icon: Icons.health_and_safety,
                    ),
                    const SizedBox(height: 12),
                 
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: studentStatusController,
                      label: 'Student Status',
                      icon: Icons.person_pin,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: pastRecordController,
                      label: 'Past Record',
                      icon: Icons.history,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: academicResultController,
                      label: 'Academic Result',
                      icon: Icons.grade,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: registrationNoController,
                      label: 'Registration Number',
                      icon: Icons.confirmation_number,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Consumer<LevelClassProvider>(
                      builder: (context, provider, _) => _buildDropdown(
                        label: 'Level',
                        value: dialogLevelId,
                        items: provider.levelsWithClasses.map((levelWithClasses) {
                          return DropdownMenuItem(
                            value: levelWithClasses.level.id,
                            child: Text(levelWithClasses.level.levelName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            dialogLevelId = value;
                            dialogClassId = null;
                          });
                        },
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
                                .firstWhere((lwc) => lwc.level.id == dialogLevelId)
                                .classes
                                .map((cls) => DropdownMenuItem(
                                      value: cls.id,
                                      child: Text(cls.className),
                                    ))
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            dialogClassId = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: studentProvider.isLoading
                            ? null
                            : () async {
                                if (surnameController.text.trim().isEmpty ||
                                    firstNameController.text.trim().isEmpty ||
                                    gender == null ||
                                    dialogLevelId == null ||
                                    dialogClassId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please fill in all required fields (Surname, First Name, Gender, Level, Class)'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
          
                                String? base64Image;
                                if (tempImage != null) {
                                  final bytes = await tempImage?.readAsBytes();
                                  base64Image = base64Encode(bytes!);
                                }
          
                                final studentData = {
                                  "photo": tempImage != null
          ? {
              "file": base64Encode(tempImage!.readAsBytesSync()),
              "file_name": path.basename(tempImage!.path),  
              "old_file_name": oldFileName                  
            }
          : (isEditing 
              ? student.photo ?? ""                     
              : ""),                                        
                                  'surname': surnameController.text.trim(),
                                  'first_name': firstNameController.text.trim(),
                                  'middle': middleNameController.text.trim(),
                                  'gender': gender,
                                  'birth_date': birthDateController.text.trim(),
                                  'address': addressController.text.trim(),
                                  'city': int.tryParse(cityController.text.trim()) ?? 0,
                                  'state': int.tryParse(stateController.text.trim()) ?? 0,
                                  'country': int.tryParse(countryController.text.trim()) ?? 0,
                                  'email': emailController.text.trim(),
                                  'religion': religionController.text.trim(),
                                  'guardian_name': guardianNameController.text.trim(),
                                  'guardian_address': guardianAddressController.text.trim(),
                                  'guardian_phone_no': guardianPhoneController.text.trim(),
                                  'lga_origin': lgaOriginController.text.trim(),
                                  'state_origin': stateOriginController.text.trim(),
                                  'nationality': nationalityController.text.trim(),
                                  'health_status': healthStatusController.text.trim(),
                                 // 'date_admitted':  birthDateController.text.trim(),
                                  'student_status': studentStatusController.text.trim(),
                                  'past_record': pastRecordController.text.trim(),
                                  'academic_result': academicResultController.text.trim(),
                                  'level_id': dialogLevelId,
                                  'class_id': dialogClassId,
                                  'registration_no': registrationNoController.text.trim(),
                                };
          
                                bool success;
                                if (isEditing) {
                                  success = await studentProvider.updateStudent(student!.id.toString(), studentData);
                                 
                                } else {
                                  success = await studentProvider.createStudent(studentData);
                                
                                }
          
                                if (success) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isEditing ? 'Student updated successfully' : 'Student added successfully'),
                                      backgroundColor: AppColors.attCheckColor2,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(studentProvider.error ?? 'Failed to ${isEditing ? 'update' : 'add'} student'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.text2Light,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: studentProvider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                isEditing ? 'Update Student' : 'Add Student',
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
              ),
            ),
          ),
        ),
      ),
    );
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
      ),
      body: studentProvider.isLoading || levelClassProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: Constants.customBoxDecoration(context),
              child: Column(
                children: [
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
                            value: selectedClassId,
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
                  Expanded(
                    child: filteredStudents.isEmpty
                        ? const Center(child: Text('No students found'))
                        : ListView.builder(
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
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => StudentProfileScreen(student: student)));
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
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete Student'),
                                              content: Text(
                                                  'Are you sure you want to delete ${student.firstName} ${student.surname}?'),
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
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
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