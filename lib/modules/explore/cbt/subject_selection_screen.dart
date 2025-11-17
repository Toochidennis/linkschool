import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';
import 'package:linkschool/modules/model/explore/home/exam_model.dart';
import 'package:linkschool/modules/explore/e_library/test_screen.dart';
import 'package:linkschool/modules/explore/e_library/cbt_result_screen.dart';
import 'package:linkschool/modules/providers/explore/exam_provider.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/providers/explore/cbt_provider.dart';

class SubjectSelectionScreen extends StatefulWidget {
  const SubjectSelectionScreen({super.key});

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  List<SelectedSubject> selectedSubjects = [];
  int totalDurationInSeconds = 3600; // Default 1 hour per subject

  @override
  void initState() {
    super.initState();
    // Show the modal automatically when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSubjectSelectionModal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My CBT Subjects',
          style: TextStyle(
            fontFamily: 'Urbanist',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.text2Light,
        foregroundColor: Colors.white,
        actions: [
          if (selectedSubjects.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton.icon(
                onPressed: () => _startTest(),
                style: ElevatedButton.styleFrom(
                
                  backgroundColor:Colors.white ,
                  foregroundColor: AppColors.eLearningBtnColor1,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.play_arrow, size: 20),
                label: Text(
                  'Start (${selectedSubjects.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
        ),
        child: selectedSubjects.isEmpty
            ? _buildEmptyState()
            : _buildSubjectList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSubjectSelectionModal(),
        backgroundColor: AppColors.eLearningBtnColor1,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Subject',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No subjects added yet',
            style: AppTextStyles.normal600(
              fontSize: 20,
              color: Colors.grey[600]!,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add your first subject',
            style: AppTextStyles.normal400(
              fontSize: 14,
              color: Colors.grey[500]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: selectedSubjects.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final subject = selectedSubjects.removeAt(oldIndex);
          selectedSubjects.insert(newIndex, subject);
          
          // Print reorder info
          print('\n🔄 Subject Reordered:');
          print('   Moved: ${subject.subjectName} (${subject.year})');
          print('   From position ${oldIndex + 1} to ${newIndex + 1}');
          print('\n📋 New Order:');
          for (int i = 0; i < selectedSubjects.length; i++) {
            final s = selectedSubjects[i];
            print('   ${i + 1}. ${s.subjectName} (${s.year}) - ID: ${s.examId}');
          }
          print('─' * 50);
        });
      },
      itemBuilder: (context, index) {
        final subject = selectedSubjects[index];
        return _buildSubjectCard(subject, index);
      },
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
        final removedSubject = selectedSubjects[index];
        setState(() {
          selectedSubjects.removeAt(index);
        });
        
        // Print removal info
        print('\n🗑️ Subject Removed:');
        print('   Subject Name: ${removedSubject.subjectName}');
        print('   Subject ID: ${removedSubject.subjectId}');
        print('   Year: ${removedSubject.year}');
        print('   Exam ID: ${removedSubject.examId}');
        print('\n📋 Remaining Subjects: ${selectedSubjects.length}');
        for (int i = 0; i < selectedSubjects.length; i++) {
          final s = selectedSubjects[i];
          print('   ${i + 1}. ${s.subjectName} (${s.year})');
          print('      Subject ID: ${s.subjectId}');
          print('      Exam ID: ${s.examId}');
        }
        print('─' * 50);
        
        
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: colors[index % colors.length],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Subject Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons/${subject.icon}.png',
                  width: 32,
                  height: 32,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.book, color: Colors.white, size: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Subject Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.subjectName,
                    style: AppTextStyles.normal600(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Year: ${subject.year}',
                    style: AppTextStyles.normal500(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Timer
                  Row(
                    children: [
                      const Icon(
                        Icons.timer,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '1 Hour',
                        style: AppTextStyles.normal600(
                          fontSize: 14,
                          color: Colors.white,
                        ),
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

  void _showSubjectSelectionModal() {
    final provider = Provider.of<CBTProvider>(context, listen: false);
    final subjects = provider.currentBoardSubjects;

    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a board first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
            final isDuplicate = selectedSubjects.any(
              (s) => s.subjectName == subject && s.year == year,
            );
            
            if (isDuplicate) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$subject ($year) is already added'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }
            
            setState(() {
              selectedSubjects.add(
                SelectedSubject(
                  subjectName: subject,
                  subjectId: subjectId,
                  year: year,
                  examId: examId,
                  icon: icon,
                ),
              );
            });
            
            // Print all IDs with subject names
            print('\n📚 Subject Added:');
            print('   Subject Name: $subject');
            print('   Subject ID: $subjectId');
            print('   Year: $year');
            print('   Exam ID: $examId');
            print('\n📋 All Selected Subjects:');
            for (int i = 0; i < selectedSubjects.length; i++) {
              final s = selectedSubjects[i];
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

  void _startTest() {
  

    // Calculate total duration (1 hour per subject)
    final totalSeconds = selectedSubjects.length * 3600;

    // Extract exam IDs in order
    final examIds = selectedSubjects.map((s) => s.examId).toList();
    final subjectNames = selectedSubjects.map((s) => s.subjectName).toList();
    final years = selectedSubjects.map((s) => s.year).toList();

    print('\n🚀 Starting Test Session:');
    print('   Total Subjects: ${selectedSubjects.length}');
    print('   Total Duration: ${totalSeconds ~/ 60} minutes');
    print('   Exam IDs: $examIds');
    print('   Subjects: $subjectNames');
    print('─' * 50);

    // Navigate to multi-subject test screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiSubjectTestScreen(
          examIds: examIds,
          subjects: subjectNames,
          years: years,
          totalDurationInSeconds: totalSeconds,
        ),
      ),
    );
  }
}

class MultiSubjectTestScreen extends StatefulWidget {
  final List<String> examIds;
  final List<String> subjects;
  final List<String> years;
  final int totalDurationInSeconds;

  const MultiSubjectTestScreen({
    super.key,
    required this.examIds,
    required this.subjects,
    required this.years,
    required this.totalDurationInSeconds,
  });

  @override
  State<MultiSubjectTestScreen> createState() => _MultiSubjectTestScreenState();
}

class _MultiSubjectTestScreenState extends State<MultiSubjectTestScreen> {
  int currentExamIndex = 0;
  late int remainingSeconds;
  Map<String, Map<int, int>> allAnswers = {}; // examId -> userAnswers
  Map<String, List<QuestionModel>> allQuestions = {}; // examId -> questions
  Map<String, String> subjectNames = {}; // examId -> subject name
  Map<String, String> subjectYears = {}; // examId -> year

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.totalDurationInSeconds;
    
    // Initialize subject mappings
    for (int i = 0; i < widget.examIds.length; i++) {
      subjectNames[widget.examIds[i]] = widget.subjects[i];
      subjectYears[widget.examIds[i]] = widget.years[i];
    }
    
    print('\n🎯 Multi-Subject Test Session Started:');
    print('   Total Subjects: ${widget.examIds.length}');
    print('   Total Duration: ${widget.totalDurationInSeconds ~/ 60} minutes');
    print('   Subjects: ${widget.subjects.join(", ")}');
    print('─' * 50);
  }

  void _loadNextExam() {
    if (currentExamIndex < widget.examIds.length - 1) {
      setState(() {
        currentExamIndex++;
      });
      print('\n📚 Loading Next Exam:');
      print('   Subject: ${widget.subjects[currentExamIndex]}');
      print('   Exam ID: ${widget.examIds[currentExamIndex]}');
      print('   Progress: ${currentExamIndex + 1}/${widget.examIds.length}');
      print('   Remaining Time: ${remainingSeconds ~/ 60} minutes');
      print('─' * 50);
    } else {
      // All exams completed - show comprehensive results
      _showFinalResults();
    }
  }

  void _showFinalResults() {
    print('\n🎉 All Exams Completed!');
    print('   Total Subjects Completed: ${widget.examIds.length}');
    print('   Total Answers Recorded: ${allAnswers.length}');
    
    int totalQuestions = 0;
    int totalAnswered = 0;
    for (var entry in allAnswers.entries) {
      final examId = entry.key;
      final answers = entry.value;
      final questions = allQuestions[examId] ?? [];
      totalQuestions += questions.length;
      totalAnswered += answers.length;
      final index = widget.examIds.indexOf(examId);
      if (index >= 0) {
        print('   ${widget.subjects[index]}: ${answers.length}/${questions.length} answered');
      }
    }
    print('   Total: $totalAnswered/$totalQuestions answered');
    print('─' * 50);
    
    // Navigate to result screen with all subject data
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => CbtResultScreen(
          questions: allQuestions[widget.examIds[0]] ?? [],
          userAnswers: allAnswers[widget.examIds[0]] ?? {},
          subject: subjectNames[widget.examIds[0]] ?? '',
          year: int.tryParse(subjectYears[widget.examIds[0]] ?? '') ?? DateTime.now().year,
          examType: 'Multi-Subject Test',
          examId: widget.examIds[0],
          calledFrom: 'multi-subject',
          isFullyCompleted: true,
          // Pass all subjects data for swiping
          allSubjectsData: widget.examIds.map((examId) {
            return {
              'questions': allQuestions[examId] ?? [],
              'userAnswers': allAnswers[examId] ?? {},
              'subject': subjectNames[examId] ?? '',
              'year': int.tryParse(subjectYears[examId] ?? '') ?? DateTime.now().year,
              'examId': examId,
            };
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastSubject = currentExamIndex == widget.examIds.length - 1;
    
    return TestScreen(
      key: ValueKey(widget.examIds[currentExamIndex]), // Force rebuild on exam change
      examTypeId: widget.examIds[currentExamIndex],
      subject: widget.subjects[currentExamIndex],
      year: int.tryParse(widget.years[currentExamIndex]),
      calledFrom: 'multi-subject',
      totalDurationInSeconds: remainingSeconds,
      isLastInMultiSubject: isLastSubject,
      currentExamIndex: currentExamIndex,
      totalExams: widget.examIds.length,
      allAnswers: allAnswers,
      allQuestions: allQuestions,
      onExamComplete: (userAnswers, remainingTime) {
        // Save answers and questions for current exam
        final currentExamId = widget.examIds[currentExamIndex];
        allAnswers[currentExamId] = Map<int, int>.from(userAnswers);
        
        // Get the current questions from provider before moving to next exam
        final provider = Provider.of<ExamProvider>(context, listen: false);
        allQuestions[currentExamId] = List<QuestionModel>.from(provider.questions);
        
        remainingSeconds = remainingTime;
        
        print('\n✅ Exam Completed:');
        print('   Subject: ${widget.subjects[currentExamIndex]}');
        print('   Questions: ${provider.questions.length}');
        print('   Questions Answered: ${userAnswers.length}');
        print('   Remaining Time: ${remainingTime ~/ 60} minutes');
        print('   Saved Questions: ${allQuestions[currentExamId]?.length ?? 0}');
        print('   Saved Answers: ${allAnswers[currentExamId]?.length ?? 0}');
        print('─' * 50);
        
        // Reset provider for next exam
        provider.reset();
        
        // Load next exam or show results
        _loadNextExam();
      },
    );
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
                //  border: Border.all(color: Colors.grey[300]!),
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
                 // border: Border.all(color: Colors.grey[300]!),
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

  void _selectSubject(SubjectModel subject) {
    setState(() {
      selectedSubject = subject;
      showYears = true;
    });
    _animationController.forward(from: 0.0);
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
