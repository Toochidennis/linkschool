import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/portal/home/result/class_detail/registration/bulk_registration.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String _selectedTerm = 'First term';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registration',
          style: AppTextStyles.normal600(
              fontSize: 18.0, color: AppColors.primaryLight),
        ),
        centerTitle: true,
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
            _buildButtonSection(),
            const SizedBox(
              height: 25,
            ),
            _buildHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopContainer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 165, // Fixed height for the container
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.regBtnColor1,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '2016/2017 academic session',
                          style: AppTextStyles.normal600(
                              fontSize: 12, color: AppColors.backgroundDark),
                        ),
                        CustomDropdown(
                          items: const [
                            'First term',
                            'Second term',
                            'Third term'
                          ],
                          value: _selectedTerm,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedTerm = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 34,
                  ),
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.regAvatarColor,
                        child:
                            Icon(Icons.person, color: AppColors.primaryLight),
                      ),
                      const SizedBox(width: 12),
                      Text('Registered students',
                          style: AppTextStyles.normal500(
                              fontSize: 14, color: AppColors.backgroundLight)),
                      const SizedBox(width: 18),
                      Container(
                          width: 1,
                          height: 40,
                          color: AppColors.backgroundLight),
                      const SizedBox(width: 18),
                      Text(
                        '345',
                        style: AppTextStyles.normal700(
                            fontSize: 24, color: AppColors.backgroundLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.videoColor4,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Reduced border radius
              ),
            ),
            child: Text(
              'Register student',
              style: AppTextStyles.normal600(
                  fontSize: 16, color: AppColors.backgroundLight),
            ),
            onPressed: () => _showRegistrationDialog(context),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  child: Text(
                    '+ Copy registration',
                    style: AppTextStyles.normal600(
                        fontSize: 12, color: AppColors.videoColor4),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.regBtnColor2,
                    side: const BorderSide(color: AppColors.videoColor4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.regBtnColor2,
                    side: const BorderSide(color: AppColors.videoColor4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text('+ Bulk registration',
                      style: AppTextStyles.normal600(
                          fontSize: 12, color: AppColors.videoColor4)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BulkRegistrationScreen())),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      padding: const EdgeInsets.all(16),
      color: AppColors.regBgColor1,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('History',
                  style: AppTextStyles.normal600(
                      fontSize: 16, color: AppColors.backgroundDark)),
              Text(
                'See all',
                style: AppTextStyles.normal500(
                        fontSize: 14, color: AppColors.barTextGray)
                    .copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                height: 90,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('2015/2016 academic session',
                            style: AppTextStyles.normal700(
                                fontSize: 14, color: AppColors.backgroundDark)),
                        SizedBox(
                          height: 24,
                          // width: 85,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 0), // Increased horizontal padding
                              backgroundColor: AppColors.backgroundLight,
                              side: const BorderSide(
                                  color: AppColors.primaryLight),
                            ),
                            child: Text('See details',
                                style: AppTextStyles.normal500(
                                    fontSize: 12,
                                    color: AppColors.primaryLight)),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text('345',
                            style: AppTextStyles.normal600(
                                fontSize: 12, color: AppColors.regTextGray)),
                        const SizedBox(width: 10),
                        Text('students registered',
                            style: AppTextStyles.normal600(
                                fontSize: 11, color: AppColors.regTextGray)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final List<String> items;
  final String value;
  final Function(String?) onChanged;

  const CustomDropdown({
    Key? key,
    required this.items,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      // width: 110,
      decoration: BoxDecoration(
        color: AppColors.videoColor4,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 1),
              child: Container(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  item,
                  style: AppTextStyles.normal600(
                      fontSize: 12, color: AppColors.backgroundDark),
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        dropdownColor: Colors.white,
        menuMaxHeight: 200,
        itemHeight: 50,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

void _showRegistrationDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(16, 16, 16, 32), // Added bottom padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select courses to register',
                style: AppTextStyles.normal600(
                    fontSize: 18, color: AppColors.backgroundDark),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ..._buildSubjectRows(),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.videoColor4,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Register',
                  style: AppTextStyles.normal600(
                      fontSize: 16, color: AppColors.backgroundLight),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

List<Widget> _buildSubjectRows() {
  List<String> allSubjects = [
    'Mathematics',
    'English',
    'Physics',
    'Chemistry',
    'Biology',
    'History',
    'Geography',
    'Literature',
    'Economics',
    'Government',
    'French',
    'Computer Science',
    'Fine Arts',
    'Music',
    'Physical Education'
  ];
  allSubjects.shuffle();

  List<Widget> rows = [];
  while (allSubjects.isNotEmpty) {
    List<String> rowSubjects = allSubjects.take(3).toList();
    allSubjects.removeRange(0, rowSubjects.length);

    rows.add(Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: rowSubjects.map((subject) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.videoColor4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(subject,
                    style: TextStyle(color: AppColors.videoColor4),
                    overflow: TextOverflow.ellipsis),
                onPressed: () {},
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }

  return rows;
}
