// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/admin/e_learning/create_syllabus_screen.dart';
import 'package:linkschool/modules/admin/e_learning/empty_subject_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/syllabus_model.dart';
import 'package:linkschool/modules/providers/admin/e_learning/syllabus_provider.dart';
import 'package:linkschool/modules/services/admin/e_learning/syllabus_service.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:provider/provider.dart';

class EmptySyllabusScreen extends StatefulWidget {
  final String selectedSubject;
  final String? courseId;
  final String? classId;
  final String? levelId;
  final String? course_name;
  final String? term;

  const EmptySyllabusScreen({
    super.key,
    required this.selectedSubject,
    this.courseId,
    this.classId,
    this.levelId,
    this.course_name,
   this.term
  });

  @override
  State<EmptySyllabusScreen> createState() => _EmptySyllabusScreenState();
}

class _EmptySyllabusScreenState extends State<EmptySyllabusScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> _syllabusList = [];
  bool isLoading = false;
  late SyllabusProvider _syllabusProvider;
  late double opacity;

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
   
    _syllabusProvider = Provider.of<SyllabusProvider>(context, listen: false);
    _loadSyllabuses();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSyllabuses(); 
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
      // Use actual widget parameters instead of hardcoded values
      final String levelId = widget.levelId ?? '';
         String term = widget.term ?? '';
    if (term.isEmpty) {
      final userBox = Hive.box('userData');
      final storedUserData = userBox.get('userData') ?? userBox.get('loginResponse');
      final processedData = storedUserData is String
          ? json.decode(storedUserData)
          : storedUserData;
      final response = processedData['response'] ?? processedData;
      final data = response['data'] ?? response;
      final settings = data['settings'] ?? {};
      term = settings['term']?.toString() ?? ''; 
    }
      print('Handler: Loading syllabuses for levelId: $levelId, term: $term');
      print('Handler: courseId: ${widget.term}, classId: ${widget.classId}');

      // Validate required parameters
      if (levelId.isEmpty) {
        throw Exception('Level ID is required but not provided');
      }
      
      await _syllabusProvider.fetchSyllabus(levelId, term);
      
      final syllabusModels = _syllabusProvider.syllabusList;
      print('Handler: Received ${syllabusModels.length} syllabus models');
      
      if (_syllabusProvider.error.isNotEmpty) {
        throw Exception(_syllabusProvider.error);
      }
      
      setState(() {
        _syllabusList.clear();
    _syllabusList.addAll(
      syllabusModels.asMap().entries.map((entry) {
        final index = entry.key;
        final syllabus = entry.value;
        if (syllabus.id == null) {
          print('Warning: Syllabus at index $index has null ID');
          return null; // Skip invalid syllabuses
        }

        final classNames = syllabus.classes
            .map((classInfo) => classInfo.name)
            .join(', ');
        final selectedClass = classNames.isEmpty ? 'No classes selected' : classNames;

        return {
          'id': syllabus.id,
          'title': syllabus.title,
          'description': syllabus.description,
          'author_name': syllabus.authorName,
          'term': syllabus.term,
          'upload_date': syllabus.uploadDate,
          'classes': syllabus.classes,
          'selectedClass': selectedClass,
          'selectedTeacher': "select a teacher",
          'backgroundImagePath': _imagePaths.isNotEmpty
              ? _imagePaths[index % _imagePaths.length]
              : '',
          // Add the missing fields with defaults
          'course_id': syllabus.courseId ?? widget.courseId ?? '',
          'course_name': syllabus.courseName ?? widget.course_name ?? '',
          'level_id': syllabus.levelId ?? widget.levelId ?? '',
          'creator_id': syllabus.creatorId ?? '',
        };
      }).whereType<Map<String, dynamic>>()
    );
      });
      
      print('Handler: Successfully processed ${_syllabusList.length} syllabuses for UI');
      
    } catch (e) {
      print('Handler Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load syllabuses: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void updateSyllabus(int index, String newTitle,String newDescription,List<ClassModel> newClasses) async{
    final int syllabusId = _syllabusList[index]['id'];
    final String term = _syllabusList[index]["term"] ;
    final String levelId = widget.levelId ?? "" ;
    SyllabusProvider syllabusProvider = Provider.of<SyllabusProvider>(context, listen: false);
     try{
       await syllabusProvider.UpdateSyllabus(
         title: newTitle,
         description: newDescription,
         term: term,
         levelId: levelId,
         syllabusId: syllabusId,
         classes: newClasses,
       );
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Syllabus updated successfully'), backgroundColor: Colors.green),
    );
       _loadSyllabuses();
     }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        
        content: Text('Failed to update syllabus: $e'), backgroundColor: Colors.red),
    );
     };
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
        child: 
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : _syllabusList.isEmpty
                ? _buildEmptyState()
                : _buildSyllabusList(),
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
    print('Building syllabus list with ${_syllabusList.length} items');
    print('Widget parameters - classId: ${widget.classId}, levelId: ${widget.levelId}, courseId: ${widget.courseId}, course_name: ${widget.course_name}');
    
    return ListView.builder(
      itemCount: _syllabusList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmptySubjectScreen(
                 syllabusId: _syllabusList[index]['id'] as int?,
                classId: widget.classId,
                courseId: widget.courseId,
                levelId: widget.levelId,
                courseName: widget.course_name,
                term: _syllabusList[index]['term']?.toString() ?? '',
                courseTitle: _syllabusList[index]['title']?.toString() ?? '',
              ),
              settings: const RouteSettings(name: '/empty_subject'),
            ),
            
          ),

          child: _buildOutlineContainers(_syllabusList[index], index),
        );
      },
    );
    
  }

  VoidCallback _addNewSyllabus() {
             
    print("Adding new syllabus with  ${widget.term} levelId: ${widget.levelId}, course_name: ${widget.course_name}");
    
    return () async {
      await Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (BuildContext context) => CreateSyllabusScreen(
            classId: widget.classId,
            courseId: widget.courseId,
            levelId: widget.levelId,
            courseName: widget.course_name,
          ),
        ),
      );
      _loadSyllabuses();
    };
  }

 void _editSyllabus(int index) async {
  final result = await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (BuildContext context) => CreateSyllabusScreen(
        syllabusData: _syllabusList[index],
        classId: widget.classId,
        courseId: widget.courseId,
        levelId: widget.levelId,
        courseName: widget.course_name,
      ),
    ),
  );

    // If the user saved changes, result should contain the new values
  if (result != null && result is Map<String, dynamic>) {
    final String newTitle = result['title'];
    final String newDescription = result['description'];
    final List<ClassModel> newClasses = result['classes'];
    updateSyllabus(index, newTitle, newDescription, newClasses);
  }

}
  void _deleteSyllabus(int index) async{
    final int syllabusId = _syllabusList[index]['id'];
    final String term = _syllabusList[index]["term"] ;
    final String levelId = widget.levelId ?? "" ;
    SyllabusProvider syllabusProvider = Provider.of<SyllabusProvider>(context, listen: false);
  await  syllabusProvider.deletesyllabus(syllabusId, levelId, term);
     _loadSyllabuses();
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
                Navigator.of(context).pop();
                _deleteSyllabus(index);
                
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



// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:linkschool/modules/admin/e_learning/create_syllabus_screen.dart';
// import 'package:linkschool/modules/admin/e_learning/empty_subject_screen.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/syllabus_provider.dart';
// import 'package:linkschool/modules/services/admin/e_learning/syllabus_service.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';
// import 'package:provider/provider.dart';

// class EmptySyllabusScreen extends StatefulWidget {
//   final String selectedSubject;
//   final String? courseId;
//   final String? classId;
//   final String? levelId;
//   final String? course_name;
//   final String? term;

//   const EmptySyllabusScreen({
//     super.key,
//     required this.selectedSubject,
//     this.courseId,
//     this.classId,
//     this.levelId,
//     this.course_name,
//     this.term
//   });

//   @override
//   State<EmptySyllabusScreen> createState() => _EmptySyllabusScreenState();
// }

// class _EmptySyllabusScreenState extends State<EmptySyllabusScreen> with WidgetsBindingObserver {
//    List<Map<String, dynamic>> _syllabusList = [];
//   bool isLoading = false;
//   late SyllabusProvider _syllabusProvider;
//   late double opacity;

//   final SyllabusProvider syllabusProvider = SyllabusProvider(SyllabusService(ApiService()));
//   // List of 5 background image paths to cycle through
//   final List<String> _imagePaths = [
//     'assets/images/result/bg_box1.svg',
//     'assets/images/result/bg_box2.svg',
//     'assets/images/result/bg_box3.svg',
//     'assets/images/result/bg_box4.svg',
//     'assets/images/result/bg_box5.svg',
//   ];

//   @override
//   void initState() {
//     super.initState();
    
//       _syllabusProvider = Provider.of<SyllabusProvider>(context, listen: false);
//     _loadSyllabuses();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       // _loadSyllabuses(); // Refresh data when returning to the screen
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

// Future<void> _loadSyllabuses() async {
//   setState(() => isLoading = true);
  
//   try {
//     // Replace with your actual values
//     const String levelId = 'your_level_id'; // Make sure this matches what your API expects
//     const String term = '3'; // Based on your JSON, term is "3"
    
//     print('Handler: Loading syllabuses for levelId: $levelId, term: $term');
    
//     await _syllabusProvider.fetchSyllabus(levelId, term);
    
//     final syllabusModels = _syllabusProvider.syllabusList;
//     print('Handler: Received ${syllabusModels.length} syllabus models');
    
//     if (_syllabusProvider.error.isNotEmpty) {
//       throw Exception(_syllabusProvider.error);
//     }
    
//     setState(() {
//       _syllabusList.clear();
//       _syllabusList.addAll(syllabusModels.asMap().entries.map((entry) {
//         final index = entry.key;
//         final syllabus = entry.value;
        
//         final classNames = syllabus.classes
//             .map((classInfo) => classInfo.name)
//             .join(', ');
//         final selectedClass = classNames.isEmpty ? 'No classes selected' : classNames;

//         return {
//           'id': syllabus.id,
//           'title': syllabus.title,
//           'description': syllabus.description,
//           'author_name': syllabus.authorName,
//           'term': syllabus.term,
//           'upload_date': syllabus.uploadDate,
//           'classes': syllabus.classes,
//           'selectedClass': selectedClass,
//           'selectedTeacher': syllabus.authorName,
//           'backgroundImagePath': _imagePaths.isNotEmpty 
//               ? _imagePaths[index % _imagePaths.length] 
//               : '',
//           // Add the missing fields with defaults
//           'course_id': syllabus.courseId ?? '',
//           'course_name': syllabus.courseName ?? '',
//           'level_id': syllabus.levelId ?? '',
//           'creator_id': syllabus.creatorId ?? '',
//         };
//       }).toList());
//     });
    
//     print('Handler: Successfully processed ${_syllabusList.length} syllabuses for UI');
    
//   } catch (e) {
//     print('Handler Error: $e');
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to load syllabuses: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   } finally {
//     setState(() => isLoading = false);
//   }
// }

//   // Placeholder for your service method
//   Future<List<dynamic>> _fetchSyllabusesFromService() async {
//     // Simulate API response (replace with your actual service call)
//     await Future.delayed(const Duration(seconds: 1));
//     return [
//       {
//         'title': 'Chikhggg',
//         'description': 'bvbbbhhhhh',
//         'image': '',
//         'image_name': '',
//         'course_id': '62',
//         'level_id': '66',
//         'class_ids': [
//           {'id': '69', 'class_name': 'JSS1A'},
//           {'id': '64', 'class_name': 'JSS1B'},
//         ],
//         'creator_role': 'admin',
//         'term': '3',
//         'year': '2025',
//         'creator_id': 15,
//       },
//       {
//         'title': 'Math Basics',
//         'description': 'Introduction to algebra',
//         'image': '',
//         'image_name': '',
//         'course_id': '63',
//         'level_id': '67',
//         'class_ids': [
//           {'id': '70', 'class_name': 'JSS2A'},
//         ],
//         'creator_role': 'teacher',
//         'term': '1',
//         'year': '2025',
//         'creator_id': 16,
//       },
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.primaryLight,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         title: Text(
//           'Syllabus',
//           style: AppTextStyles.normal600(
//               fontSize: 24.0, color: AppColors.primaryLight),
//         ),
//         backgroundColor: AppColors.backgroundLight,
//         flexibleSpace: FlexibleSpaceBar(
//           background: Stack(
//             children: [
//               Positioned.fill(
//                 child: Opacity(
//                   opacity: opacity,
//                   child: Image.asset(
//                     'assets/images/background.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//       body: Container(
//         decoration: Constants.customBoxDecoration(context),
//         child: 
//         isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : _syllabusList.isEmpty
//                 ? _buildEmptyState()
//                 : _buildSyllabusList(),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _addNewSyllabus(),
//         backgroundColor: AppColors.videoColor4,
//         child: SvgPicture.asset(
//           'assets/icons/e_learning/plus.svg',
//           color: Colors.white,
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         const Text('No syllabus have been created'),
//         const SizedBox(height: 15),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             CustomMediumElevatedButton(
//               text: 'Create new syllabus',
//               onPressed: _addNewSyllabus(),
//               backgroundColor: AppColors.eLearningBtnColor1,
//               textStyle: AppTextStyles.normal600(
//                 fontSize: 16,
//                 color: AppColors.backgroundLight,
//               ),
//               padding: const EdgeInsets.all(12),
//             )
//           ],
//         )
//       ],
//     );
    
//   }

//   Widget _buildSyllabusList() {
//     print(widget.classId);
//     print(widget.levelId);
//     print(widget.courseId);
//     print(widget.course_name);  
//     return ListView.builder(
//       itemCount: _syllabusList.length,
//       itemBuilder: (context, index) {
//         return GestureDetector(
//   onTap: () => Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => EmptySubjectScreen(
//         classId: widget.classId,
//         courseId: widget.courseId,
//         levelId: widget.levelId,
//         courseName: widget.course_name,
//         courseTitle: _syllabusList[index]['title']?.toString() ?? '',
//       ),
//       settings: RouteSettings(name: '/empty_subject'),
//     ),
//   ),
//   child: _buildOutlineContainers(_syllabusList[index], index),
// );
        
//       },
//     );
   
//   }

//   VoidCallback _addNewSyllabus() {

//     print("SSSSSSSSSSSSSSSSSSSSSSSSSSSS ${widget.levelId} ");
//      print("SSSSSSSSSSSSSSSSSSSSSSSSSSSS ${widget.course_name} ");
//     return () async {
//       await Navigator.of(context).push(
//         MaterialPageRoute(
//           fullscreenDialog: true,
//           builder: (BuildContext context) => CreateSyllabusScreen(
//             classId: widget.classId,
//             courseId: widget.courseId,
//             levelId: widget.levelId,
//              courseName: widget.course_name,
//           ),
          
//         ),
         
//       );
//       _loadSyllabuses();
//       // No need to add result since CreateSyllabusScreen doesn't pass data
//       // _loadSyllabuses will handle updates via API
//     };
//   }

//   void _editSyllabus(int index) async {
//     await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (BuildContext context) => CreateSyllabusScreen(
//           syllabusData: _syllabusList[index],
//           classId: widget.classId,
//           courseId: widget.courseId,
//           levelId: widget.levelId,
//         ),
//       ),
//     );
//     // No need to update _syllabusList since CreateSyllabusScreen doesn't pass data
//     // _loadSyllabuses will handle updates via API
//   }

//   void _deleteSyllabus(int index) {
//     setState(() {
//       _syllabusList.removeAt(index);
//     });
//   }

//   void _confirmDeleteSyllabus(int index) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(
//             'Delete Syllabus',
//             style: AppTextStyles.normal600(
//               fontSize: 20,
//               color: AppColors.backgroundDark,
//             ),
//           ),