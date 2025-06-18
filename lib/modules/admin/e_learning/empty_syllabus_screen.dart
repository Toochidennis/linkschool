// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/admin/e_learning/create_syllabus_screen.dart';
import 'package:linkschool/modules/admin/e_learning/empty_subject_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class EmptySyllabusScreen extends StatefulWidget {
  final String selectedSubject;
  final String? courseId;
  final String? classId;
  final String? levelId;
  final String? course_name;

  const EmptySyllabusScreen({
    super.key,
    required this.selectedSubject,
    this.courseId,
    this.classId,
    this.levelId,
    this.course_name
  });

  @override
  State<EmptySyllabusScreen> createState() => _EmptySyllabusScreenState();
}

class _EmptySyllabusScreenState extends State<EmptySyllabusScreen> with WidgetsBindingObserver {
  final List<Map<String, dynamic>> _syllabusList = [];
  late double opacity;
  bool isLoading = true;
  // List of 5 background image paths to cycle through
  final List<String> _imagePaths = [
    'assets/images/result/bg_box1.svg',
    'assets/images/result/bg_box2.svg',
    'assets/images/result/bg_box3.svg',
    'assets/images/result/bg_box4.svg',
    'assets/images/result/bg_box5.svg',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // _loadSyllabuses();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // _loadSyllabuses(); // Refresh data when returning to the screen
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadSyllabuses() async {
    setState(() => isLoading = true);
    try {
      // Replace with your actual service/provider call
      final List<dynamic> data = await _fetchSyllabusesFromService();

      setState(() {
        _syllabusList.clear();
        _syllabusList.addAll(data.asMap().entries.map((entry) {
          final index = entry.key;
          final syllabus = entry.value as Map<String, dynamic>;
          // Derive selectedClass from class_ids
          final classIds = (syllabus['class_ids'] as List<dynamic>?) ?? [];
          final classNames = classIds
              .map((cls) => cls['class_name']?.toString() ?? 'Unknown')
              .join(', ');
          final selectedClass = classNames.isEmpty ? 'No classes selected' : classNames;

          return {
            'title': syllabus['title']?.toString() ?? '',
            'description': syllabus['description']?.toString() ?? '',
            'image': syllabus['image']?.toString() ?? '',
            'image_name': syllabus['image_name']?.toString() ?? '',
            'course_id': syllabus['course_id']?.toString() ?? '',
            'level_id': syllabus['level_id']?.toString() ?? '',
            'class_ids': classIds,
            'creator_role': syllabus['creator_role']?.toString() ?? '',
            'term': syllabus['term']?.toString() ?? '',
            'year': syllabus['year']?.toString() ?? '',
            'creator_id': syllabus['creator_id'] ?? 0,
            'selectedClass': selectedClass,
            'selectedTeacher': 'Not assigned', // Placeholder
            'backgroundImagePath': _imagePaths[index % _imagePaths.length], // Cycle through 5 images
          };
        }).toList());
      });
    } catch (e) {
      print('Error loading syllabuses: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading syllabuses: $e')),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Placeholder for your service method
  Future<List<dynamic>> _fetchSyllabusesFromService() async {
    // Simulate API response (replace with your actual service call)
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        'title': 'Chikhggg',
        'description': 'bvbbbhhhhh',
        'image': '',
        'image_name': '',
        'course_id': '62',
        'level_id': '66',
        'class_ids': [
          {'id': '69', 'class_name': 'JSS1A'},
          {'id': '64', 'class_name': 'JSS1B'},
        ],
        'creator_role': 'admin',
        'term': '3',
        'year': '2025',
        'creator_id': 15,
      },
      {
        'title': 'Math Basics',
        'description': 'Introduction to algebra',
        'image': '',
        'image_name': '',
        'course_id': '63',
        'level_id': '67',
        'class_ids': [
          {'id': '70', 'class_name': 'JSS2A'},
        ],
        'creator_role': 'teacher',
        'term': '1',
        'year': '2025',
        'creator_id': 16,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
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
        title: Text(
          'Syllabus',
          style: AppTextStyles.normal600(
              fontSize: 24.0, color: AppColors.primaryLight),
        ),
        backgroundColor: AppColors.backgroundLight,
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: opacity,
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: FutureBuilder<List<dynamic>>(
          future: _fetchSyllabusesFromService(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              _syllabusList.clear();
              _syllabusList.addAll(snapshot.data!.asMap().entries.map((entry) {
                final index = entry.key;
                final syllabus = entry.value as Map<String, dynamic>;
                // Derive selectedClass from class_ids
                final classIds = (syllabus['class_ids'] as List<dynamic>?) ?? [];
                final classNames = classIds
                    .map((cls) => cls['class_name']?.toString() ?? 'Unknown')
                    .join(', ');
                final selectedClass = classNames.isEmpty ? 'No classes selected' : classNames;

                return {
                  'title': syllabus['title']?.toString() ?? '',
                  'description': syllabus['description']?.toString() ?? '',
                  'image': syllabus['image']?.toString() ?? '',
                  'image_name': syllabus['image_name']?.toString() ?? '',
                  'course_id': syllabus['course_id']?.toString() ?? '',
                  'level_id': syllabus['level_id']?.toString() ?? '',
                  'class_ids': classIds,
                  'creator_role': syllabus['creator_role']?.toString() ?? '',
                  'term': syllabus['term']?.toString() ?? '',
                  'year': syllabus['year']?.toString() ?? '',
                  'creator_id': syllabus['creator_id'] ?? 0,
                  'selectedClass': selectedClass,
                  'selectedTeacher': 'Not assigned', // Placeholder
                  'backgroundImagePath': _imagePaths[index % _imagePaths.length], // Cycle through 5 images
                };
              }).toList());

              return _syllabusList.isEmpty ? _buildEmptyState() : _buildSyllabusList();
            }
          },
        ),
        // isLoading
        //     ? const Center(child: CircularProgressIndicator())
        //     : _syllabusList.isEmpty
        //         ? _buildEmptyState()
        //         : _buildSyllabusList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSyllabus(),
        backgroundColor: AppColors.videoColor4,
        child: SvgPicture.asset(
          'assets/icons/e_learning/plus.svg',
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('No syllabus have been created'),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomMediumElevatedButton(
              text: 'Create new syllabus',
              onPressed: _addNewSyllabus(),
              backgroundColor: AppColors.eLearningBtnColor1,
              textStyle: AppTextStyles.normal600(
                fontSize: 16,
                color: AppColors.backgroundLight,
              ),
              padding: const EdgeInsets.all(12),
            )
          ],
        )
      ],
    );
    
  }

  Widget _buildSyllabusList() {
    print(widget.classId);
    print(widget.levelId);
    print(widget.courseId);
    print(widget.course_name);  
    return ListView.builder(
      itemCount: _syllabusList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmptySubjectScreen(
                classId: widget.classId,
            courseId: widget.courseId,
            levelId: widget.levelId,
            courseName: widget.course_name,
                courseTitle: _syllabusList[index]['title']?.toString() ?? '',
              ),
            ),
            
          ),
          child: _buildOutlineContainers(_syllabusList[index], index),
        );
        
      },
    );
   
  }

  VoidCallback _addNewSyllabus() {

    print("SSSSSSSSSSSSSSSSSSSSSSSSSSSS ${widget.levelId} ");
     print("SSSSSSSSSSSSSSSSSSSSSSSSSSSS ${widget.course_name} ");
    return () async {
      await Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (BuildContext context) => CreateSyllabusScreen(
            classId: widget.classId,
            courseId: widget.courseId,
            levelId: widget.levelId,
          ),
          
        ),
         
      );
     
      // No need to add result since CreateSyllabusScreen doesn't pass data
      // _loadSyllabuses will handle updates via API
    };
  }

  void _editSyllabus(int index) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => CreateSyllabusScreen(
          syllabusData: _syllabusList[index],
          classId: widget.classId,
          courseId: widget.courseId,
          levelId: widget.levelId,
        ),
      ),
    );
    // No need to update _syllabusList since CreateSyllabusScreen doesn't pass data
    // _loadSyllabuses will handle updates via API
  }

  void _deleteSyllabus(int index) {
    setState(() {
      _syllabusList.removeAt(index);
    });
  }

  void _confirmDeleteSyllabus(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Syllabus',
            style: AppTextStyles.normal600(
              fontSize: 20,
              color: AppColors.backgroundDark,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this syllabus?',
            style: AppTextStyles.normal500(
              fontSize: 16,
              color: AppColors.backgroundDark,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'No',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteSyllabus(index);
                Navigator.of(context).pop();
              },
              child: Text(
                'Yes',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOutlineContainers(Map<String, dynamic> syllabus, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.transparent,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (syllabus['backgroundImagePath'] != null)
              SvgPicture.asset(
                syllabus['backgroundImagePath'] as String,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          syllabus['title']?.toString() ?? '',
                          style: AppTextStyles.normal700(
                            fontSize: 18,
                            color: AppColors.backgroundLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/result/edit.svg',
                          color: Colors.white,
                          width: 20,
                          height: 20,
                        ),
                        onPressed: () => _editSyllabus(index),
                      ),
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/result/delete.svg',
                          color: Colors.white,
                          width: 20,
                          height: 20,
                        ),
                        onPressed: () => _confirmDeleteSyllabus(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    syllabus['selectedClass']?.toString() ?? '',
                    style: AppTextStyles.normal500(
                      fontSize: 18,
                      color: AppColors.backgroundLight,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    syllabus['selectedTeacher']?.toString() ?? '',
                    style: AppTextStyles.normal600(
                      fontSize: 14,
                      color: AppColors.backgroundLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}