import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';
import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
import 'package:linkschool/modules/providers/explore/challange/challange_provider.dart';
import 'package:linkschool/modules/services/explore/manage_storage.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/challange_modal.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/challange_instruction.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/start_challenge.dart';
import 'package:provider/provider.dart';

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();

  late final PageController _pageController;
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  String _challengeStatus = 'draft';
  
  DateTime? _startDate;
  DateTime? _endDate;
  List<SelectedSubject> _selectedSubjects = [];
  
  // Challenge settings
  int timeInMinutes = 60; // Default 60 minutes
  int? questionLimit = 40; // Default 40 questions
  
  // Dropdown options
  final List<int> timeOptions = [90, 60, 40, 30, 20, 10]; // minutes (biggest to lowest)
  final List<int> questionOptions = [60, 50, 45, 40]; // questions (biggest to lowest)
  
  // Subject selection variables
  final List<Map<String, dynamic>> _staticSubjects = [
    {'name': 'Mathematics', 'icon': Icons.calculate, 'color': Color(0xFF6366F1)},
    {'name': 'Science', 'icon': Icons.science, 'color': Color(0xFF10B981)},
    {'name': 'English', 'icon': Icons.menu_book, 'color': Color(0xFF8B5CF6)},
    {'name': 'History', 'icon': Icons.history_edu, 'color': Color(0xFFEC4899)},
    {'name': 'Geography', 'icon': Icons.public, 'color': Color(0xFF06B6D4)},
    {'name': 'Biology', 'icon': Icons.biotech, 'color': Color(0xFFF59E0B)},
    {'name': 'Physics', 'icon': Icons.bolt, 'color': Color(0xFFEF4444)},
    {'name': 'Chemistry', 'icon': Icons.science_outlined, 'color': Color(0xFF14B8A6)},
    {'name': 'Computer Science', 'icon': Icons.computer, 'color': Color(0xFF3B82F6)},
    {'name': 'Art', 'icon': Icons.palette, 'color': Color(0xFFF97316)},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _pageController = PageController();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _pageController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Color(0xFF6366F1),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black87,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        final DateTime selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );

        setState(() {
          if (isStartDate) {
            _startDate = selectedDateTime;
          } else {
            _endDate = selectedDateTime;
          }
        });
      }
    }
  }

  void _showSubjectSelectionModal() {
    final provider = Provider.of<CBTProvider>(context, listen: false);
    final subjects = provider.currentBoardSubjects;

    // Use dynamic subjects from provider if available, otherwise use static subjects
    if (subjects.isNotEmpty) {
      _showDynamicSubjectModal(subjects);
    } else {
      _showStaticSubjectModal();
    }
  }

  void _showDynamicSubjectModal(List<SubjectModel> subjects) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SubjectYearSelectionModal(
          subjects: subjects,
          onSubjectYearSelected: (subject, subjectId, year, examId, icon) {
            // Check if this subject with the same year already exists
            final isDuplicate = _selectedSubjects.any(
              (s) => s.subjectName == subject && s.year == year,
            );
            
            if (isDuplicate) {
              Navigator.of(context).pop();
              _showErrorSnackBar('$subject ($year) is already added');
              return;
            }
            
            setState(() {
              _selectedSubjects.add(
                SelectedSubject(
                  subjectName: subject,
                  subjectId: subjectId,
                  year: year,
                  examId: examId,
                  icon: icon,
                ),
              );
            });
            
            print('\n📚 Subject Added to Challenge:');
            print('   Subject Name: $subject');
            print('   Subject ID: $subjectId');
            print('   Year: $year');
            print('   Exam ID: $examId');
            print('\n📋 All Selected Subjects:');
            for (int i = 0; i < _selectedSubjects.length; i++) {
              final s = _selectedSubjects[i];
              print('   ${i + 1}. ${s.subjectName} (${s.year})');
              print('      Subject ID: ${s.subjectId}');
              print('      Exam ID: ${s.examId}');
            }
            print('─' * 50);
            
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showStaticSubjectModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Subject',
                style: AppTextStyles.normal600(
                  fontSize: 22,
                  color: AppColors.text3Light,
                ),
              ),
              const SizedBox(height: 24),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _staticSubjects.length,
                  itemBuilder: (context, index) {
                    final subject = _staticSubjects[index];
                    final isSelected = _selectedSubjects.any(
                      (s) => s.subjectName == subject['name']
                    );

                    return GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          _showErrorSnackBar('${subject['name']} is already added');
                          return;
                        }
                        
                        setState(() {
                          _selectedSubjects.add(
                            SelectedSubject(
                              subjectName: subject['name'],
                              subjectId: subject['name'].toLowerCase().replaceAll(' ', '_'),
                              year: '2024', // Default year for static subjects
                              examId: '${subject['name'].toLowerCase().replaceAll(' ', '_')}_2024',
                              icon: 'default',
                            ),
                          );
                        });
                        
                        Navigator.of(context).pop();
                        _showSuccessSnackBar('${subject['name']} added successfully');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? subject['color'].withOpacity(0.1) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? subject['color'] : Colors.grey[300]!,
                            width: isSelected ? 2 : 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              subject['icon'],
                              color: isSelected ? subject['color'] : Colors.grey[600],
                              size: 28,
                            ),
                            SizedBox(height: 6),
                            Text(
                              subject['name'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected ? subject['color'] : Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _removeSubject(int index) {
    final removedSubject = _selectedSubjects[index];
    setState(() {
      _selectedSubjects.removeAt(index);
    });
    
    _showSuccessSnackBar('${removedSubject.subjectName} removed');
    
    print('\n🗑️ Subject Removed from Challenge:');
    print('   Subject Name: ${removedSubject.subjectName}');
    print('   Subject ID: ${removedSubject.subjectId}');
    print('   Year: ${removedSubject.year}');
    print('   Exam ID: ${removedSubject.examId}');
    print('\n📋 Remaining Subjects: ${_selectedSubjects.length}');
  }
void _submitChallenge() async {
  final provider = Provider.of<ChallengeProvider>(context, listen: false);
  
  // Validation checks
  if (_startDate == null) {
    _showErrorSnackBar('Please select a start date');
    return;
  }
  if (_endDate == null) {
    _showErrorSnackBar('Please select an end date');
    return;
  }
  if (_selectedSubjects.isEmpty) {
    _showErrorSnackBar('Please select at least one subject');
    return;
  }
  if (_endDate!.isBefore(_startDate!)) {
    _showErrorSnackBar('End date must be after start date');
    return;
  }

  // Create API payload
  final apiPayload = {
    'title': _titleController.text,
    'description': _descriptionController.text,
    'points': int.tryParse(_pointsController.text) ?? 0,
    'start_date': _startDate!.toIso8601String(),
    'end_date': _endDate!.toIso8601String(),
    'time_limit': timeInMinutes,
    'question_limit': questionLimit,
    'exam_ids': _selectedSubjects.map((subject) => subject.examId).toList(),
    'course_names': _selectedSubjects.map((subject) => subject.subjectName).toList(),
    'course_ids': _selectedSubjects.map((subject) => subject.subjectId).toList(),
      'status': _challengeStatus,
  };

  // Create local storage data
  final challengeData = {
    'id': 'challenge_${DateTime.now().millisecondsSinceEpoch}',
    'title': _titleController.text,
    'description': _descriptionController.text,
    'points': int.tryParse(_pointsController.text) ?? 0,
    'startDate': _startDate!.toIso8601String(),
    'endDate': _endDate!.toIso8601String(),
    'timeInMinutes': timeInMinutes,
    'questionLimit': questionLimit,
    'subjects': _selectedSubjects.map((subject) => {
      'subjectName': subject.subjectName,
      'subjectId': subject.subjectId,
      'year': subject.year,
      'examId': subject.examId,
      'icon': subject.icon,
    }).toList(),
    'createdAt': DateTime.now().toIso8601String(),
    'participants': 0,
    'difficulty': 'Medium',
    'status': 'active',
    'synced': false,
      'status': _challengeStatus,
  };

  // Show loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Text('Creating challenge...'),
        ],
      ),
    ),
  );

  try {
    // First: Call API endpoint
    await provider.createChallenge(apiPayload);
    
    // Check if there's an error from the provider
    if (provider.error != null && provider.error!.isNotEmpty) {
      // API call failed
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorSnackBar('Failed to create challenge: ${provider.error}');
      return;
    }
    
    // Second: If API call succeeds, save to SharedPreferences
    await ChallengeService.saveChallenge(challengeData);
    
    // Close loading dialog
    Navigator.of(context).pop();
    
    // Show success dialog with challenge details
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CreationSuccessDialog(
        title: _titleController.text,
        description: _descriptionController.text,
        subjects: _selectedSubjects,
        points: int.tryParse(_pointsController.text) ?? 0,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
  } catch (e) {
    // Close loading dialog
    Navigator.of(context).pop();
    _showErrorSnackBar('Error creating challenge: ${e.toString()}');
    print('Error: $e');
  }
}

  void _previewChallenge() {
    // Create a temporary challenge model for preview
    final previewChallenge = ChallengeModel(
      title: _titleController.text.isNotEmpty ? _titleController.text : 'Preview Challenge',
      description: _descriptionController.text,
      icon: Icons.preview,
      xp: int.tryParse(_pointsController.text) ?? 0,
      gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      participants: 0,
      difficulty: 'Medium',
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate ?? DateTime.now().add(Duration(days: 1)),
      subjects: _selectedSubjects,
      isCustomChallenge: true,
      timeInMinutes: timeInMinutes,
      questionLimit: questionLimit,
    );

    // Extract exam IDs, subject names, and years from selected subjects
    final examIds = _selectedSubjects.map((subject) => subject.examId).toList();
    final subjectNames = _selectedSubjects.map((subject) => subject.subjectName).toList();
    final years = _selectedSubjects.map((subject) => subject.year).toList();

    print('\n👁️ Previewing Challenge:');
    print('   Title: ${previewChallenge.title}');
    print('   Subjects: ${subjectNames.length}');
    print('   Exam IDs: $examIds');

    // Navigate to instructions screen (same as join challenge flow)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeInstructionsScreen(
          challenge: previewChallenge,
          onContinue: () {
            // Navigate to StartChallenge with exam data
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StartChallenge(
                  challenge: previewChallenge,
                  examIds: examIds,
                  subjectNames: subjectNames,
                  years: years,
                  totalDurationInSeconds: timeInMinutes * 60,
                  questionLimit: questionLimit,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSelectedSubjectsList() {
    if (_selectedSubjects.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          'No subjects added yet. Tap "Add Subjects" to get started.',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          textAlign: TextAlign.left,
        ),
      );
    }

    return Column(
      children: _selectedSubjects.asMap().entries.map((entry) {
        final index = entry.key;
        final subject = entry.value;
        return _buildSubjectCard(subject, index);
      }).toList(),
    );
  }

  Widget _buildSubjectCard(SelectedSubject subject, int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    return Dismissible(
      key: Key('${subject.subjectName}_${subject.year}_${subject.examId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _removeSubject(index);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors[index % colors.length].withOpacity(0.8),
              colors[index % colors.length].withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.book,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.subjectName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Year: ${subject.year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
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

  Widget _buildStatusDropdown() {
  return Container(
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _challengeStatus == 'published' 
                ? Icons.public 
                : Icons.save,
              color: const Color(0xFF6366F1),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Challenge Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _showStatusSelectionModal();
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _challengeStatus == 'published'
                                ? Colors.green.withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _challengeStatus == 'published' 
                              ? Icons.public 
                              : Icons.drafts,
                            color: _challengeStatus == 'published'
                                ? Colors.green
                                : Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _challengeStatus == 'published' 
                                ? 'Publish Now' 
                                : 'Save as Draft',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _challengeStatus == 'published'
                                ? 'Challenge will be visible to others'
                                : 'Only you can see this challenge',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey.shade500,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

void _showStatusSelectionModal() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Status',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            
            // Draft Option
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _challengeStatus = 'draft';
                  });
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _challengeStatus == 'draft'
                        ? Colors.blue.withOpacity(0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _challengeStatus == 'draft'
                          ? Colors.blue
                          : Colors.grey.shade300,
                      width: _challengeStatus == 'draft' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.drafts,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Save as Draft',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Only you can see and edit this challenge',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_challengeStatus == 'draft')
                        Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Publish Option
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _challengeStatus = 'published';
                  });
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _challengeStatus == 'published'
                        ? Colors.green.withOpacity(0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _challengeStatus == 'published'
                          ? Colors.green
                          : Colors.grey.shade300,
                      width: _challengeStatus == 'published' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.public,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Publish Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Make challenge visible to other users',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_challengeStatus == 'published')
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Challenge',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Design your own challenge',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // PageView Sections
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                children: [
                  _buildDetailsSection(),
                  _buildSubjectSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return SingleChildScrollView(
      key: ValueKey('details'),
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('Challenge Title', Icons.title),
            SizedBox(height: 12),
            _buildTextField(
              controller: _titleController,
              hint: 'Enter challenge title',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            _buildSectionLabel('Description', Icons.description),
            SizedBox(height: 12),
            _buildTextField(
              controller: _descriptionController,
              hint: 'Describe your challenge',
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Start Date', Icons.calendar_today),
                      SizedBox(height: 12),
                      _buildDateSelector(
                        context,
                        _startDate,
                        'Select start date',
                        true,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('End Date', Icons.event),
                      SizedBox(height: 12),
                      _buildDateSelector(
                        context,
                        _endDate,
                        'Select end date',
                        false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildSectionLabel('Points Reward', Icons.stars),
            SizedBox(height: 12),
            _buildTextField(
              controller: _pointsController,
              hint: 'Enter XP points',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter points';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF6366F1).withOpacity(0.4),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      if (_startDate == null) {
                        _showErrorSnackBar('Please select a start date');
                        return;
                      }
                      if (_endDate == null) {
                        _showErrorSnackBar('Please select an end date');
                        return;
                      }
                      if (_endDate!.isBefore(_startDate!)) {
                        _showErrorSnackBar('End date must be after start date');
                        return;
                      }
                      
                      // Navigate to next page
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Time Dropdown
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time (minutes):',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<int>(
                    value: timeInMinutes,
                    isExpanded: true,
                    underline: const SizedBox(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    items: timeOptions.map((time) {
                      return DropdownMenuItem(
                        value: time,
                        child: Text('${time} mins'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          timeInMinutes = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Number of Questions Dropdown
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Number of Questions:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<int>(
                    value: questionLimit ?? 40,
                    isExpanded: true,
                    underline: const SizedBox(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    items: questionOptions.map((questions) {
                      return DropdownMenuItem(
                        value: questions,
                        child: Text('$questions'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          questionLimit = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildSubjectSection() {
  return SingleChildScrollView(
    key: const ValueKey('subject'),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputSection(), // Time + Questions dropdown
        const SizedBox(height: 24),
         _buildStatusDropdown(),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionLabel('Subjects', Icons.category),
            ElevatedButton.icon(
              onPressed: _showSubjectSelectionModal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text(
                'Add Subjects',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSelectedSubjectsList(),
        
        const SizedBox(height: 30),
        Row(
          children: [
            // Preview Button (Expanded to take half width)
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF6366F1), width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _selectedSubjects.isNotEmpty ? _previewChallenge : null,
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.preview,
                            color: _selectedSubjects.isNotEmpty
                                ? const Color(0xFF6366F1)
                                : Colors.grey,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Preview',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _selectedSubjects.isNotEmpty
                                  ? const Color(0xFF6366F1)
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16), // Spacing between buttons
            
            // Create Challenge Button (Expanded to take half width)
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _submitChallenge,
                    borderRadius: BorderRadius.circular(16),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Create',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Back Button
        Center(
          child: TextButton(
            onPressed: () {
              _pageController.previousPage(
                duration: Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
            child: const Text('Back', style: TextStyle(color: Color(0xFF6366F1))),
          ),
        ),
        const SizedBox(height: 40), // Extra bottom padding for scroll
      ],
    ),
  );
}
  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red[400]!, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    DateTime? date,
    String placeholder,
    bool isStartDate,
  ) {
    return GestureDetector(
      onTap: () => _selectDate(context, isStartDate),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: date != null ? Color(0xFF6366F1) : Colors.grey[300]!,
            width: date != null ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: date != null ? Color(0xFF6366F1) : Colors.grey[400],
              size: 18,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                date != null
                    ? DateFormat('MMM dd, yyyy\nhh:mm a').format(date)
                    : placeholder,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: date != null ? Colors.black87 : Colors.grey[400],
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreationSuccessDialog extends StatefulWidget {
  final String title;
  final String description;
  final List<SelectedSubject> subjects;
  final int points;
  final DateTime? startDate;
  final DateTime? endDate;

  const _CreationSuccessDialog({
    required this.title,
    required this.description,
    required this.subjects,
    required this.points,
    this.startDate,
    this.endDate,
  });

  @override
  State<_CreationSuccessDialog> createState() => _CreationSuccessDialogState();
}

class _CreationSuccessDialogState extends State<_CreationSuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleController.forward();
    Future.delayed(Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.blue.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Icon
                _buildAnimatedIcon(),
                SizedBox(height: 24),

                // Title
                SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    'Challenge Created!',
                    style: AppTextStyles.normal700(
                      fontSize: 28,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 16),

                // Description
                SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    'Your challenge "${widget.title}" has been created successfully!',
                    style: AppTextStyles.normal500(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 24),

                // Stats
              //  _buildStats(),

                SizedBox(height: 32),

                // Action Buttons
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Transform.rotate(
            angle: (1 - value) * 0.5,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.teal.shade600],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_circle,
                size: 70,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStats() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.subject,
                    '${widget.subjects.length}',
                    'Subjects',
                    Colors.blue.shade500,
                  ),
                ),
                Container(
                  height: 50,
                  width: 1.5,
                  color: Colors.grey.shade200,
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.star,
                    '${widget.points}',
                    'Points',
                    Colors.amber.shade600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Subjects Added:',
              style: AppTextStyles.normal600(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            ...widget.subjects.map((subject) => 
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${subject.subjectName} (${subject.year})',
                  style: AppTextStyles.normal500(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
            fontFamily: 'Urbanist',
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.normal500(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade500, Colors.indigo.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade400.withOpacity(0.4),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Text(
                    'Done',
                    style: AppTextStyles.normal600(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectedSubject {
  final String subjectName;
  final String subjectId;
  final String year;
  final String examId;
  final String icon;

  SelectedSubject({
    required this.subjectName,
    required this.subjectId,
    required this.year,
    required this.examId,
    required this.icon,
  });
  
  @override
  String toString() {
    return 'SelectedSubject{subject: $subjectName, subjectId: $subjectId, year: $year, examId: $examId}';
  }
}

class SubjectYearSelectionModal extends StatefulWidget {
  final List<SubjectModel> subjects;
  final Function(String subject, String subjectId, String year, String examId, String icon) onSubjectYearSelected;

  const SubjectYearSelectionModal({
    super.key,
    required this.subjects,
    required this.onSubjectYearSelected,
  });

  @override
  State<SubjectYearSelectionModal> createState() =>
      _SubjectYearSelectionModalState();
}

class _SubjectYearSelectionModalState extends State<SubjectYearSelectionModal>
    with SingleTickerProviderStateMixin {
  SubjectModel? selectedSubject;
  bool showYears = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            Text(
              showYears ? 'Select Year' : 'Select Subject',
              style: AppTextStyles.normal600(
                fontSize: 22,
                color: AppColors.text3Light,
              ),
            ),
            if (showYears && selectedSubject != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  selectedSubject!.name,
                  style: AppTextStyles.normal500(
                    fontSize: 16,
                    color: AppColors.text7Light,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Flexible(
              child: !showYears
                  ? _buildSubjectList()
                  : SlideTransition(
                      position: _slideAnimation,
                      child: _buildYearList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildSubjectList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.subjects.length,
      itemBuilder: (context, index) {
        final subject = widget.subjects[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _selectSubject(subject),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: subject.cardColor ?? AppColors.cbtCardColor1,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/${subject.subjectIcon ?? 'default'}.png',
                          width: 28,
                          height: 28,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.book, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        subject.name,
                        style: AppTextStyles.normal600(
                          fontSize: 16,
                          color: AppColors.text3Light,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectSubject(SubjectModel subject) {
    setState(() {
      selectedSubject = subject;
      showYears = true;
    });
    _animationController.forward(from: 0.0);
  }

  Widget _buildYearList() {
    if (selectedSubject == null || selectedSubject!.years == null) {
      return const Center(child: Text('No years available'));
    }

    // Sort years in descending order (most recent first)
    final sortedYears = List.from(selectedSubject!.years!)
      ..sort((a, b) => b.year.compareTo(a.year));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedYears.length,
    
      itemBuilder: (context, index) {
        final year = sortedYears[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                widget.onSubjectYearSelected(
                  selectedSubject!.name,
                  selectedSubject!.id,
                  year.year,
                  year.id,
                  selectedSubject!.subjectIcon ?? 'default',
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      year.year,
                      style: AppTextStyles.normal600(
                        fontSize: 16,
                        color: AppColors.text3Light,
                      ),
                    ),
                    const Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: AppColors.eLearningBtnColor1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}