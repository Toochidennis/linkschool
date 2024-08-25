import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/e_learning/select_classes_dialog.dart';
import 'package:linkschool/modules/common/widgets/portal/e_learning/select_teachers_dialog.dart';


class CreateSyllabusScreen extends StatefulWidget {
  const CreateSyllabusScreen({Key? key}) : super(key: key);

  @override
  _CreateSyllabusScreenState createState() => _CreateSyllabusScreenState();
}

class _CreateSyllabusScreenState extends State<CreateSyllabusScreen> {
  String _selectedClass = 'Select classes';
  String _selectedTeacher = 'Rapheal Nnachi';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _backgroundImagePath = 'assets/images/result/bg_box3.svg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Syllabus',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.primaryLight,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0), // Adding some padding for better alignment
            child: CustomSaveElevatedButton(
              onPressed: () {
                
                Navigator.of(context).pop({
                  'title': _titleController.text,
                  'backgroundImagePath': _backgroundImagePath,
                  'description': _descriptionController.text,
                  'selectedClass': _selectedClass,
                  'selectedTeacher': _selectedTeacher,
                });
              }, 
              text: 'Save',
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title:',
              style:
                  AppTextStyles.normal600(fontSize: 16.0, color: Colors.black),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Dying and bleaching',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.all(12.0),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Description:',
              style:
                  AppTextStyles.normal600(fontSize: 16.0, color: Colors.black),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Type here...',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.all(12.0),
              ),
            ),
            const SizedBox(height: 32.0),
            Text(
              'Select the learning group for this syllabus: *',
              style:
                  AppTextStyles.normal600(fontSize: 16.0, color: Colors.black),
            ),
            const SizedBox(height: 16.0),
            _buildGroupRow(
              context,
              iconPath: 'assets/icons/e_learning/people.svg',
              text: _selectedClass,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SelectClassesDialog(
                      onSave: (selectedClass) {
                        setState(() {
                          _selectedClass = selectedClass;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            _buildGroupRow(
              context,
              iconPath: 'assets/icons/e_learning/profile.svg',
              text: _selectedTeacher,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SelectTeachersDialog(
                      onSave: (selectedTeacher) {
                        setState(() {
                          _selectedTeacher = selectedTeacher;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupRow(BuildContext context,
      {required String iconPath,
      required String text,
      required VoidCallback onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  iconPath,
                  width: 32.0,
                  height: 32.0,
                ),
              ),
              const SizedBox(width: 8.0),
              IntrinsicWidth(
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.eLearningBtnColor2,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Text(
                        text,
                        style: AppTextStyles.normal600(
                            fontSize: 16.0,
                            color: AppColors.eLearningBtnColor1),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        Divider(
          color: Colors.grey.withOpacity(0.5),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }
}
