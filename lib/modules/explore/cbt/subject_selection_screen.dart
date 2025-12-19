import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';
import 'package:linkschool/modules/model/explore/home/exam_model.dart';
import 'package:linkschool/modules/explore/e_library/test_screen.dart';
import 'package:linkschool/modules/explore/e_library/cbt_result_screen.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/providers/explore/exam_provider.dart';
import 'package:linkschool/modules/services/cbt_subscription_service.dart';
import 'package:linkschool/modules/explore/e_library/widgets/subscription_enforcement_dialog.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
import 'package:linkschool/modules/common/cbt_settings_helper.dart';

// Convert a string to sentence case: all lowercase then first letter uppercase
String _sentenceCase(String input) {
  if (input.isEmpty) return input;

  return input.toLowerCase().split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + (word.length > 1 ? word.substring(1) : '');
  }).join(' ');
}

class SubjectSelectionScreen extends StatefulWidget {
  const SubjectSelectionScreen({super.key});

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  final _subscriptionService = CbtSubscriptionService();
  List<SelectedSubject> selectedSubjects = [];
  int totalDurationInSeconds = 3600; // Default 1 hour per subject
  int timeInMinutes = 60; // Default 60 minutes
  int? questionLimit = 40; // Default 40 questions

  // Dropdown options
  final List<int> timeOptions = [
    60,
    45,
    40,
    35,
    30,
    25,
    20,
    10
  ]; // minutes (biggest to lowest)
  final List<int> questionOptions = [
    60,
    55,
    50,
    45,
    40,
    35,
    30,
    25,
    10
  ]; // questions (biggest to lowest)

  @override
  void initState() {
    super.initState();
    // Show the modal automatically when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSubjectSelectionModal();
    });
  }

  @override
  void dispose() {
    super.dispose();
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
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.eLearningBtnColor1,
                  elevation: 2,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: Column(
          children: [
            _buildInputSection(),
            Expanded(
              child: selectedSubjects.isEmpty
                  ? _buildEmptyState()
                  : _buildSubjectList(),
            ),
          ],
        ),
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

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  style: AppTextStyles.normal600(
                    fontSize: 14,
                    color: AppColors.text3Light,
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
                        child: Text('${time}mins'),
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
                  style: AppTextStyles.normal600(
                    fontSize: 14,
                    color: AppColors.text3Light,
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
            print(
                '   ${i + 1}. ${s.subjectName} (${s.year}) - ID: ${s.examId}');
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
                    // Display subject name in sentence case
                    _sentenceCase(subject.subjectName),
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
                        '$timeInMinutes Minutes',
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
            final formattedSubject = _sentenceCase(subject);

            // Check if this subject with the same year already exists
            final isDuplicate = selectedSubjects.any(
              (s) => s.subjectName == formattedSubject && s.year == year,
            );

            if (isDuplicate) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$formattedSubject ($year) is already added'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            setState(() {
              selectedSubjects.add(
                SelectedSubject(
                  subjectName: formattedSubject,
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

  Future<void> _startTest() async {
    final userProvider = Provider.of<CbtUserProvider>(context, listen: false);

    // ✨ PRIMARY CHECK: Use CbtUserProvider's payment status (from backend)
    final hasUserPaid = userProvider.hasPaid;

    // ✨ SECONDARY CHECK: Use subscription service (local storage)
    final canTakeTest = await _subscriptionService.canTakeTest();
    final remainingTests = await _subscriptionService.getRemainingFreeTests();

    print('\n💳 Payment Check:');
    print('   - Backend says paid: $hasUserPaid');
    print('   - Local says can take test: $canTakeTest');
    print('   - Remaining free tests: $remainingTests');

    // If backend confirms payment, allow test
    if (hasUserPaid) {
      print('✅ User has paid (verified from backend) - starting test');
      _proceedWithTest();
      return;
    }

    // If not paid and can't take test (exceeded free limit)
    if (!canTakeTest) {
      print('❌ User must pay - showing enforcement dialog');
      if (!mounted) return;

      final settings = await CbtSettingsHelper.getSettings();
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SubscriptionEnforcementDialog(
          isHardBlock: true,
          remainingTests: remainingTests,
          amount: settings.amount,
          discountRate: settings.discountRate,
          onSubscribed: () async {
            print('✅ User subscribed from Subject Selection');
            // Refresh user data from backend
            await userProvider.refreshCurrentUser();
            if (mounted) {
              setState(() {});
            }
          },
        ),
      );
      return;
    }

    // User can take test (within free limit)
    print('✅ User can take test (within free limit) - starting test');
    _proceedWithTest();
  }

  void _proceedWithTest() {
    // Calculate total duration: time per subject × number of subjects
    final totalSeconds = timeInMinutes * 60 * selectedSubjects.length;

    // Extract exam IDs in order
    final examIds = selectedSubjects.map((s) => s.examId).toList();
    final subjectNames = selectedSubjects.map((s) => s.subjectName).toList();
    final years = selectedSubjects.map((s) => s.year).toList();

    print('\n🚀 Starting Test Session:');
    print('   Total Subjects: ${selectedSubjects.length}');
    print('   Time per Subject: $timeInMinutes minutes');
    print('   Total Duration: ${totalSeconds ~/ 60} minutes');
    print('   Question Limit: ${questionLimit ?? "All"}');

    // Directly navigate to multi-subject test screen (countdown will be shown in TestScreen)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiSubjectTestScreen(
          examIds: examIds,
          subjects: subjectNames,
          years: years,
          totalDurationInSeconds: totalSeconds,
          questionLimit: questionLimit,
        ),
      ),
    );
  }

  void _showStartTestCountdown(List<String> examIds, List<String> subjectNames,
      List<String> years, int totalSeconds) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _StartTestCountdownDialog(
        totalSubjects: selectedSubjects.length,
        onComplete: () {
          Navigator.of(context).pop(); // Close dialog

          // Navigate to multi-subject test screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MultiSubjectTestScreen(
                examIds: examIds,
                subjects: subjectNames,
                years: years,
                totalDurationInSeconds: totalSeconds,
                questionLimit: questionLimit,
              ),
            ),
          );
        },
      ),
    );
  }
}

class MultiSubjectTestScreen extends StatefulWidget {
  final List<String> examIds;
  final List<String> subjects;
  final List<String> years;
  final int totalDurationInSeconds;
  final int? questionLimit;

  const MultiSubjectTestScreen({
    super.key,
    required this.examIds,
    required this.subjects,
    required this.years,
    required this.totalDurationInSeconds,
    this.questionLimit,
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
    print('   Question Limit: ${widget.questionLimit ?? "All"}');
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
        print(
            '   ${widget.subjects[index]}: ${answers.length}/${questions.length} answered');
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
          year: int.tryParse(subjectYears[widget.examIds[0]] ?? '') ??
              DateTime.now().year,
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
              'year': int.tryParse(subjectYears[examId] ?? '') ??
                  DateTime.now().year,
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
      key: ValueKey(
          widget.examIds[currentExamIndex]), // Force rebuild on exam change
      examTypeId: widget.examIds[currentExamIndex],
      subject: widget.subjects[currentExamIndex],
      year: int.tryParse(widget.years[currentExamIndex]),
      calledFrom: 'multi-subject',
      totalDurationInSeconds: remainingSeconds,
      questionLimit: widget.questionLimit,
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
        allQuestions[currentExamId] =
            List<QuestionModel>.from(provider.questions);

        remainingSeconds = remainingTime;

        print('\n✅ Exam Completed:');
        print('   Subject: ${widget.subjects[currentExamIndex]}');
        print('   Questions: ${provider.questions.length}');
        print('   Questions Answered: ${userAnswers.length}');
        print('   Remaining Time: ${remainingTime ~/ 60} minutes');
        print(
            '   Saved Questions: ${allQuestions[currentExamId]?.length ?? 0}');
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
  final Function(String subject, String subjectId, String year, String examId,
      String icon) onSubjectYearSelected;

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

  // Search state
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _goBackToSubjects() {
    if (_isSearching) {
      _toggleSearch();
      return;
    }
    setState(() {
      showYears = false;
      selectedSubject = null;
      _searchQuery = '';
      _searchController.clear();
    });

    _animationController.reverse();
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  if (showYears)
                    IconButton(
                      onPressed: _goBackToSubjects,
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                  Expanded(
                    child: _isSearching
                        ? TextField(
                            controller: _searchController,
                            autofocus: true,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: showYears
                                  ? 'Search years...'
                                  : 'Search subjects...',
                              hintStyle: AppTextStyles.normal400(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: AppTextStyles.normal600(
                              fontSize: 18,
                              color: AppColors.text3Light,
                            ),
                          )
                        : Text(
                            showYears ? 'Select Year' : 'Select Subject',
                            style: AppTextStyles.normal600(
                              fontSize: 22,
                              color: AppColors.text3Light,
                            ),
                          ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isSearching ? Icons.close : Icons.search,
                      color: AppColors.text3Light,
                    ),
                    onPressed: _toggleSearch,
                  ),
                ],
              ),
            ),
            if (showYears && selectedSubject != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  // Header should show sentence-cased subject name
                  _sentenceCase(selectedSubject!.name),
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
    // Create a sorted copy of the subjects (A -> Z) and display sentence-case names
    var sortedSubjects = List<SubjectModel>.from(widget.subjects)
      ..sort((a, b) => _sentenceCase(a.name).compareTo(_sentenceCase(b.name)));

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      sortedSubjects = sortedSubjects
          .where(
              (s) => _sentenceCase(s.name).toLowerCase().contains(_searchQuery))
          .toList();
    }

    if (sortedSubjects.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No subjects found',
                style: AppTextStyles.normal600(
                  fontSize: 18,
                  color: AppColors.text3Light,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: AppTextStyles.normal400(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedSubjects.length,
      itemBuilder: (context, index) {
        final subject = sortedSubjects[index];
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
                        // Display subject name in sentence case
                        _sentenceCase(subject.name),
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
    var sortedYears = List.from(selectedSubject!.years!)
      ..sort((a, b) => b.year.compareTo(a.year));

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      sortedYears = sortedYears
          .where((y) => y.year.toLowerCase().contains(_searchQuery))
          .toList();
    }

    if (sortedYears.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No years found',
                style: AppTextStyles.normal600(
                  fontSize: 18,
                  color: AppColors.text3Light,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: AppTextStyles.normal400(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                _onYearSelected(year.id, year.year);
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
      // Clear search when subject is selected
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
    _animationController.forward(from: 0.0);
  }

  // When a year is tapped, the modal calls this callback and we should pass a
  // sentence-cased subject name to the parent callback.
  void _onYearSelected(String yearId, String yearValue) {
    if (selectedSubject == null) return;
    widget.onSubjectYearSelected(
      _sentenceCase(selectedSubject!.name),
      selectedSubject!.id,
      yearValue,
      yearId,
      selectedSubject!.subjectIcon ?? 'default',
    );
  }
}

class _StartTestCountdownDialog extends StatefulWidget {
  final int totalSubjects;
  final VoidCallback onComplete;

  const _StartTestCountdownDialog({
    required this.totalSubjects,
    required this.onComplete,
  });

  @override
  State<_StartTestCountdownDialog> createState() =>
      _StartTestCountdownDialogState();
}

class _StartTestCountdownDialogState extends State<_StartTestCountdownDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int _countdown = 3;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (_countdown > 1) {
          setState(() {
            _countdown--;
          });
          _controller.reset();
          _controller.forward();
          _startCountdown();
        } else {
          widget.onComplete();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.eLearningBtnColor1,
              AppColors.eLearningBtnColor1.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_circle_outline,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Starting Test!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              widget.totalSubjects == 1
                  ? 'Preparing your test...'
                  : 'Starting ${widget.totalSubjects} subjects test',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 32),

            // Countdown container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      '$_countdown',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w700,
                        color: AppColors.eLearningBtnColor1,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Progress indicator
            Text(
              'Get ready...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                fontFamily: 'Urbanist',
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
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
