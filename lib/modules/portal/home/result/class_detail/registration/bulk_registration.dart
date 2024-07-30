// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/portal/home/result/class_detail/registration/course_registration.dart';
import 'package:linkschool/modules/portal/home/result/class_detail/registration/registration.dart';

class BulkRegistrationScreen extends StatefulWidget {
  @override
  State<BulkRegistrationScreen> createState() => _BulkRegistrationScreenState();
}

class _BulkRegistrationScreenState extends State<BulkRegistrationScreen> {
  String _selectedTerm = 'First term';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
             Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopContainer(),
            SizedBox(height: 32,),
            _buildStudentList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopContainer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 165,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: SvgPicture.asset(
                'assets/images/result/top_container.svg',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.regBgColor1,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '2016/2017 academic session',
                          style: AppTextStyles.normal600(fontSize: 12, color: AppColors.backgroundDark),
                        ),
                        CustomDropdown(items: const [
                          'First term',
                          'Second term',
                          'Third term',
                        ], value: _selectedTerm, onChanged: (newValue) {
                          setState(() {
                            _selectedTerm = newValue!;
                          });
                        })
                      ],
                    ),
                  ),
                  const SizedBox(height: 34,),
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.regAvatarColor,
                        child: Icon(Icons.person, color: AppColors.primaryLight, weight: 20.0,),
                      ),
                      const SizedBox(width: 12,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Students', style: AppTextStyles.normal500(fontSize: 14, color: AppColors.backgroundLight)),
                          const SizedBox(height: 5.0,),
                          Text('345', style: AppTextStyles.normal700(fontSize: 17, color: AppColors.backgroundLight)),
                        ],
                      ),
                      SizedBox(width: 25,),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.backgroundLight,
                      ),
                      const SizedBox(width: 25,),
                      CircleAvatar(
                        backgroundColor: AppColors.backgroundLight,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/result/book.svg',
                            color: AppColors.primaryLight,
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Course Registered', style: AppTextStyles.normal500(fontSize: 14, color: AppColors.backgroundLight)),
                          const SizedBox(height: 5.0,),
                          Text('345', style: AppTextStyles.normal700(fontSize: 17, color: AppColors.backgroundLight)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
        _buildStudentListItem('Toochukwu Dennis', 0),
        _buildStudentListItem('Toochukwu Dennis', 2),
        _buildStudentListItem('Toochukwu Dennis', 1),
        _buildStudentListItem('Toochukwu Dennis', 3),
        _buildStudentListItem('Toochukwu Dennis', 0),
        _buildStudentListItem('Toochukwu Dennis', 1),
        _buildStudentListItem('Toochukwu Dennis', 2),
        _buildStudentListItem('Toochukwu Dennis', 0),
        _buildStudentListItem('Toochukwu Dennis', 1),
        _buildStudentListItem('Toochukwu Dennis', 3),
        ],
      ),
    );
  }

  Widget _buildStudentListItem(String name, int coursesRegistered) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.person, color: AppColors.backgroundLight),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundDark),
                  ),
                  SizedBox(height: 8,),
                  Text(
                    '$coursesRegistered courses registered',
                    style: AppTextStyles.normal400(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
ElevatedButton(
  onPressed: () {
    if (coursesRegistered > 0) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CourseRegistrationScreen(studentName: name, coursesRegistered: coursesRegistered),
        ),
      );
    } else {
      // Handle the "Register" case if needed
    }
  },
  child: Text(coursesRegistered > 0 ? 'Edit' : 'Register', style: AppTextStyles.normal700(fontSize: 12, color: AppColors.backgroundLight)),
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.videoColor4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
),
          ],
        ),
        Divider(),
      ],
    );
  }
}