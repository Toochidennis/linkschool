import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';
import 'package:linkschool/modules/providers/explore/challenge/challenge_provider.dart';
import 'package:linkschool/modules/providers/explore/challenge/challenge_subject_provider.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/challange_modal.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/start_challenge.dart';
import 'package:provider/provider.dart';

class CreateChallengeScreen extends StatefulWidget {
  final String userName;
  final int userId;
  final String examTypeId;
   final ChallengeModel? challengeToEdit; // Add this
  final bool isEditing;

  const CreateChallengeScreen({super.key, required this.userName, required this.userId, required this.examTypeId, this.challengeToEdit, this.isEditing = false,});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}
class _CreateChallengeScreenState extends State<CreateChallengeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();

  late final PageController _pageController;
  int _currentPageIndex = 0;
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _challengeStatus = 'draft';
  String?  _challengeId;
  
  DateTime? _startDate;
  DateTime? _endDate;
  final Set<String> _selectedSubjectIds = {};
  List<SelectedSubject> _selectedSubjects = [];
  List<SubjectModel> _challengeSubjects = [];
  bool _isLoadingChallengeSubjects = true;
  
  // Challenge settings
  int timeInMinutes = 60; // Default 60 minutes
  int? questionLimit = 25; // Default 25 questions


  // Dropdown options
  final List<int> timeOptions =  [10, 20, 25, 30, 35, 40, 45, 60]; // minutes (lowest to highest)
  final List<int> questionOptions = [5, 10, 15, 20, 25]; // questions (lowest to highest)
  static const Color _inputBorderColor = Color(0xFFD1D5DB);
  
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
  static const List<Color> _subjectAccentColors = [
    Color(0xFF0F766E),
    Color(0xFF2563EB),
    Color(0xFFDC2626),
    Color(0xFF16A34A),
    Color(0xFFB45309),
    Color(0xFF4F46E5),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _pageController = PageController();
    _pageController.addListener(_handlePageChanged);
    _animationController.forward();

    Future.microtask(_loadChallengeSubjects);

   if (widget.isEditing && widget.challengeToEdit != null) {
    Future.microtask(() => _initializeWithExistingChallenge());
  }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _pageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handlePageChanged() {
    final nextIndex = _pageController.page?.round() ?? 0;
    if (nextIndex != _currentPageIndex && mounted) {
      setState(() {
        _currentPageIndex = nextIndex;
      });
    }
  }


  void _initializeWithExistingChallenge() {
  final challenge = widget.challengeToEdit!;

  setState(() {
    _challengeId = challenge.id;
    _titleController.text = challenge.title;
    _descriptionController.text = challenge.description;
    _startDate = challenge.startDate;
    _endDate = challenge.endDate;
    _challengeStatus = challenge.status ?? 'draft';
    timeInMinutes = challenge.timeInMinutes ?? 60;
    questionLimit = (challenge.questionLimit ?? 25).clamp(5, 25).toInt();

    _selectedSubjects = [];
    _selectedSubjectIds.clear();

    if (challenge.subjects != null && challenge.subjects!.isNotEmpty) {
      _selectedSubjects = challenge.subjects!.map((s) {
        return SelectedSubject(
          subjectName: s.subjectName,
          subjectId: s.subjectId ?? '',
              year: s.year,
              examId: s.examId,
              icon: s.icon ?? 'default',
              questionCount: s.questionCount.clamp(5, 25).toInt(),
              selectedYears: s.selectedYears,
        );
      }).toList();

      for (final subject in _selectedSubjects) {
        _selectedSubjectIds.add(subject.subjectId);
      }
    }
  });

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

  Future<void> _showDurationPicker() async {
    int selectedDuration = timeInMinutes;

    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Select Duration',
                            style: AppTextStyles.normal700(
                              fontSize: 18,
                              color: AppColors.text3Light,
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context, selectedDuration),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF6366F1),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: timeOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final duration = timeOptions[index];
                        final isSelected = selectedDuration == duration;
                        return Material(
                          color: isSelected
                              ? const Color(0xFF6366F1).withValues(alpha: 0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setModalState(() {
                                selectedDuration = duration;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF6366F1)
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$duration minutes',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? const Color(0xFF6366F1)
                                          : const Color(0xFF333333),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF6366F1),
                                    )
                                  else
                                    Icon(
                                      Icons.circle_outlined,
                                      color: Colors.grey.shade300,
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
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        timeInMinutes = selected;
      });
    }
  }

  Future<void> _loadChallengeSubjects() async {
    final provider =
        Provider.of<ChallengeSubjectProvider>(context, listen: false);
    final examTypeId = int.tryParse(widget.examTypeId) ?? 0;

    if (examTypeId <= 0) {
      if (!mounted) return;
      setState(() {
        _challengeSubjects = [];
        _isLoadingChallengeSubjects = false;
      });
      return;
    }

    await provider.loadChallengeSubjects(examTypeId);

    final resolvedSubjects = provider.subjects.map((course) {
      return SubjectModel(
        id: course.courseId.toString(),
        name: course.courseName,
        subjectIcon: course.iconName,
        cardColor: course.cardColor,
        years: course.years
            .map(
              (year) => YearModel(
                id: year.examId.toString(),
                year: year.year,
              ),
            )
            .toList(),
      );
    }).toList();

    if (!mounted) return;
    setState(() {
      _challengeSubjects = resolvedSubjects;
      _isLoadingChallengeSubjects = false;
    });
  }

  Future<void> _showSubjectSelectionModal() async {
    if (_isLoadingChallengeSubjects && _challengeSubjects.isEmpty) {
      await _loadChallengeSubjects();
      if (!mounted) return;
    }

    final subjects = _challengeSubjects.isNotEmpty
        ? _challengeSubjects
        : <SubjectModel>[];

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
            
            for (int i = 0; i < _selectedSubjects.length; i++) {
              final s = _selectedSubjects[i];
            }
            
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Subject',
                    style: AppTextStyles.normal600(
                      fontSize: 22,
                      color: AppColors.text3Light,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 24,
                      color: Colors.black87,
                    ),
                  ),
                ],
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
                          color: isSelected ? subject['color'].withValues(alpha: 0.1) : Colors.grey[50],
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
    
  }

  SubjectModel? _findSubjectById(String subjectId) {
    for (final subject in _challengeSubjects) {
      if (subject.id == subjectId) {
        return subject;
      }
    }
    return null;
  }

  int _stableHash(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  Color _accentForSubject(SubjectModel subject) {
    final key = _stableHash(subject.id.isNotEmpty ? subject.id : subject.name);
    return _subjectAccentColors[key % _subjectAccentColors.length];
  }

  Map<String, List<SelectedSubject>> _groupSelectedSubjectRows() {
    final grouped = <String, List<SelectedSubject>>{};

    for (final row in _selectedSubjects) {
      final key = '${row.subjectId}__${row.subjectName}';
      grouped.putIfAbsent(key, () => []).add(row);
    }

    return grouped;
  }

  void _prepareReviewSubjects() {
    final selectedSubjects = _challengeSubjects
        .where((subject) => _selectedSubjectIds.contains(subject.id))
        .toList();

    final existingBySubject = <String, List<SelectedSubject>>{};
    for (final row in _selectedSubjects) {
      existingBySubject.putIfAbsent(row.subjectId, () => []).add(row);
    }

    final nextRows = <SelectedSubject>[];
    for (final subject in selectedSubjects) {
      final existingRows = existingBySubject[subject.id];

      if (existingRows != null && existingRows.isNotEmpty) {
        nextRows.addAll(existingRows);
      } else {
        nextRows.add(
          SelectedSubject(
            subjectName: subject.name,
            subjectId: subject.id,
              year: '',
              examId: '',
              icon: subject.subjectIcon ?? 'default',
              questionCount: questionLimit ?? 25,
              selectedYears: const [],
            ),
          );
      }
    }

    setState(() {
      _selectedSubjects = nextRows;
    });
  }

  void _toggleSubjectSelection(SubjectModel subject) {
    setState(() {
      if (_selectedSubjectIds.contains(subject.id)) {
        _selectedSubjectIds.remove(subject.id);
      } else {
        _selectedSubjectIds.add(subject.id);
      }
    });
  }

  void _addYearRowForSubject(String subjectId) {
    final subject = _findSubjectById(subjectId);
    if (subject == null) return;

    if (subject.years == null || subject.years!.isEmpty) {
      _showErrorSnackBar('No years available for ${subject.name}');
      return;
    }

    setState(() {
      _selectedSubjects.add(
        SelectedSubject(
          subjectName: subject.name,
          subjectId: subject.id,
          year: '',
          examId: '',
          icon: subject.subjectIcon ?? 'default',
          questionCount: questionLimit ?? 25,
          selectedYears: const [],
        ),
      );
    });
  }

  void _removeSelectedRow(SelectedSubject row) {
    setState(() {
      _selectedSubjects.remove(row);
    });

    final hasRemainingSubjectRows =
        _selectedSubjects.any((item) => item.subjectId == row.subjectId);
    if (!hasRemainingSubjectRows) {
      _selectedSubjectIds.remove(row.subjectId);
    }
  }

  List<YearModel> _yearsForRow(SelectedSubject row) {
    if (row.selectedYears.isNotEmpty) {
      return row.selectedYears;
    }

    if (row.year.isNotEmpty && row.examId.isNotEmpty) {
      return [
        YearModel(
          id: row.examId,
          year: row.year,
        ),
      ];
    }

    return const <YearModel>[];
  }

  String _yearSummaryForRow(SelectedSubject row) {
    final selectedYears = _yearsForRow(row);
    if (selectedYears.isEmpty) {
      return 'Select year';
    }

    if (selectedYears.length > 1) {
      return '${selectedYears.length} years selected';
    }

    final year = selectedYears.first.year;
    return year == DateTime.now().year.toString()
        ? '$year (Simulation)'
        : year;
  }

  Future<void> _showYearPickerForRow(SelectedSubject row) async {
    final subject = _findSubjectById(row.subjectId);
    final years = subject?.years ?? const <YearModel>[];

    if (subject == null || years.isEmpty) {
      _showErrorSnackBar('No years available for ${row.subjectName}');
      return;
    }

    final sortedYears = List<YearModel>.from(years)
      ..sort((a, b) => b.year.compareTo(a.year));

    final selectedRowIndex = _selectedSubjects.indexOf(row);
    if (selectedRowIndex == -1) return;
    final initialSelectedIds = _yearsForRow(row).map((year) => year.id).toSet();
    final selectedIds = <String>{...initialSelectedIds};

    final selected = await showModalBottomSheet<List<YearModel>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Select Year',
                            style: AppTextStyles.normal700(
                              fontSize: 18,
                              color: AppColors.text3Light,
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: selectedIds.isEmpty
                            ? null
                            : () {
                                Navigator.pop(
                                  context,
                                  sortedYears
                                      .where((year) => selectedIds.contains(year.id))
                                      .toList(),
                                );
                              },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF6366F1),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: sortedYears.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final year = sortedYears[index];
                        final isSelected = selectedIds.contains(year.id);
                        return Material(
                          color: isSelected
                              ? const Color(0xFF6366F1).withValues(alpha: 0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  selectedIds.remove(year.id);
                                } else {
                                  selectedIds.add(year.id);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF6366F1)
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    year.year,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? const Color(0xFF6366F1)
                                          : const Color(0xFF333333),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF6366F1),
                                    )
                                  else
                                    Icon(
                                      Icons.circle_outlined,
                                      color: Colors.grey.shade300,
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
            );
          },
        );
      },
    );

    if (selected == null) return;

    setState(() {
      _selectedSubjects[selectedRowIndex] = SelectedSubject(
        subjectName: row.subjectName,
        subjectId: row.subjectId,
        year: selected.first.year,
        examId: selected.first.id,
        icon: row.icon,
        questionCount: row.questionCount,
        selectedYears: selected,
      );
    });
  }

  void _updateQuestionCount(SelectedSubject row, int value) {
    final index = _selectedSubjects.indexOf(row);
    if (index == -1) return;

    setState(() {
      _selectedSubjects[index] = SelectedSubject(
        subjectName: row.subjectName,
        subjectId: row.subjectId,
        year: row.year,
        examId: row.examId,
        icon: row.icon,
        questionCount: value,
        selectedYears: row.selectedYears,
      );
    });
  }
Future<void> _submitChallenge({required String status}) async {
  final provider = Provider.of<ChallengeProvider>(context, listen: false);
  
  // Validation checks
  if (_startDate == null) {
    _showErrorSnackBar('Please select a start date');
    return;
  }
  if (_endDate == null) {
    _showErrorSnackBar('Please Select An End Date');
    return;
  }
  if (_startDate == _endDate) {
    _showErrorSnackBar('Start Date And End Date Cannot Be The Same');
    return;
  }
  if (_selectedSubjects.isEmpty) {
    _showErrorSnackBar('Please Select At Least One Subject');
    return;
  }
  if (_endDate!.isBefore(_startDate!)) {
    _showErrorSnackBar('End Date Must Be After Start Date');
    return;
  }
  final invalidSubjectRow = _selectedSubjects.where(
    (subject) => _yearsForRow(subject).isEmpty,
  ).toList();
  if (invalidSubjectRow.isNotEmpty) {
    _showErrorSnackBar('Select a year for every subject row');
    return;
  }

  final itemsPayload = <Map<String, dynamic>>[];
  for (final subject in _selectedSubjects) {
    final years = _yearsForRow(subject);
    itemsPayload.add({
      'course_name': subject.subjectName,
      'course_id': subject.subjectId is int
          ? subject.subjectId
          : int.tryParse(subject.subjectId) ?? 0,
      'years': years.isNotEmpty
          ? years
              .map(
                (year) => int.tryParse(year.year) ?? year.year,
              )
              .toList()
          : [int.tryParse(subject.year) ?? subject.year],
      'question_count': subject.questionCount,
    });
  }

  // Create API payload
  final apiPayload = {
    'title': _titleController.text,
    'description': _descriptionController.text,
    'start_date': _startDate!.toIso8601String(),
    'end_date': _endDate!.toIso8601String(),
    'duration': timeInMinutes,
    'items': itemsPayload,
    'status': status,
    'author_id': widget.userId.toString(), // Replace with actual user ID
    'author_name': widget.userName, // Replace with actual user name
    'exam_type_id': int.tryParse(widget.examTypeId) ?? 0, // Replace with actual exam type ID

  };
  // Create local storage data
  // final challengeData = {
  //   'id': 'challenge_${DateTime.now().millisecondsSinceEpoch}',
  //   'title': _titleController.text,
  //   'description': _descriptionController.text,
  //   'startDate': _startDate!.toIso8601String(),
  //   'endDate': _endDate!.toIso8601String(),
  //   'timeInMinutes': timeInMinutes,
  //   'questionLimit': questionLimit,
  //   'subjects': _selectedSubjects.map((subject) => {
  //     'subjectName': subject.subjectName,
  //     'subjectId': subject.subjectId,
  //     'year': subject.year,
  //     'examId': subject.examId,
  //     'icon': subject.icon,
  //   }).toList(),
  //   'createdAt': DateTime.now().toIso8601String(),
  //   'participants': 0,
  //   'difficulty': 'Medium',
  //   'status': 'active',
  //   'synced': false,
  //     'status': _challengeStatus,
  // };

  // Show loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Text(widget.isEditing ? 'Updating Challenge...' : 'Creating Challenge...'),
        ],
      ),
    ),
  );

  try {
     
     if (widget.isEditing && _challengeId != null) {
      // Update existing challenge
        final int challengeIdInt = int.tryParse(_challengeId.toString()) ?? 0;
      await provider.updateChallenges(
        authorId: widget.userId,
        payload: apiPayload,
        challengeId: challengeIdInt,
      );
    } else {
      // Create new challenge
       await provider.createChallenge(apiPayload);
    
    }

     if (provider.error != null && provider.error!.isNotEmpty) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorSnackBar('Failed: ${provider.error}');
      return;
    }
     Navigator.of(context).pop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CreationSuccessDialog(
        title: _titleController.text,
        description: _descriptionController.text,
        subjects: _selectedSubjects,
        startDate: _startDate,
        endDate: _endDate,
         isEditing: widget.isEditing,

      ),
    );
  } catch (e) {
    // Close loading dialog
    Navigator.of(context).pop();
    _showErrorSnackBar('Error creating challenge: ${e.toString()}');
  }
}

 void _previewChallenge() {
  final previewChallenge = ChallengeModel(
    id: widget.isEditing && _challengeId != null ? _challengeId : null, // optional, for display
    title: _titleController.text.isNotEmpty ? _titleController.text : 'Preview Challenge',
    description: _descriptionController.text,
    icon: Icons.preview,
    xp: 0,
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

  final courseIds = _selectedSubjects.map((s) => s.subjectId).toList();
  final subjectNames = _selectedSubjects.map((s) => s.subjectName).toList();
  final years = _selectedSubjects.expand((s) {
    final selectedYears = _yearsForRow(s);
    if (selectedYears.isEmpty) {
      return [s.year];
    }
    return selectedYears.map((year) => year.year);
  }).toList();

  // THIS IS THE IMPORTANT LINE
  final int? previewChallengeId = widget.isEditing && _challengeId != null
      ? int.tryParse(_challengeId!) // _challengeId is String?
      : null;


  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => StartChallenge(
        challenge: previewChallenge,
        challengeId: previewChallengeId,           // Ã¢â€ Â pass it here
        examIds: courseIds,
        subjectNames: subjectNames,
        years: [...years],
        totalDurationInSeconds: timeInMinutes * 60,
        questionLimit: questionLimit,
        isPreview: true,
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
              colors[index % colors.length].withValues(alpha: 0.8),
              colors[index % colors.length].withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                    _titleCase(subject.subjectName),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 56,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () {
              if (_pageController.hasClients && _currentPageIndex > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                );
              } else {
                Navigator.pop(context);
              }
            },
           
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.black87,
              ),
            
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create Challenge',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                height: 1.1,
              ),
            ),
            Text(
              'Design your own challenge',
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.grey[600],
                height: 1.1,
              ),
            ),
          ],
        ),
        actions: [
          if (_currentPageIndex == 2)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: _previewChallenge,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.visibility_outlined,
                        size: 18,
                        color: Color(0xFF6366F1),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Preview',
                        style: AppTextStyles.normal600(
                          fontSize: 13,
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildDetailsSection(),
                _buildSubjectSection(),
                _buildSubjectReviewSection(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _currentPageIndex == 0
          ? _buildDetailsActionBar()
          : _currentPageIndex == 2
              ? _buildReviewActionBar()
              : null,
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
            const SizedBox(height: 10),
            _buildTextField(
              controller: _titleController,
              
              hint: 'Enter challenge title',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Title cannot be empty';
                }
                
                if (value.length > 100) {
                  return 'Title cannot exceed 100 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildSectionLabel('Description', Icons.description),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _descriptionController,
              hint: 'Describe your challenge',
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Description cannot be empty';
                }
            
                if (value.length > 500) {
                  return 'Description cannot exceed 500 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _buildSectionLabel('Start Date', Icons.calendar_today),
            const SizedBox(height: 10),
            _buildDateSelector(
              context,
              _startDate,
              'Select start date',
              true,
            ),
            const SizedBox(height: 20),
            _buildSectionLabel('End Date', Icons.event),
            const SizedBox(height: 10),
            _buildDateSelector(
              context,
              _endDate,
              'Select end date',
              false,
            ),
            const SizedBox(height: 14),
            _buildSectionLabel('Duration', Icons.timer),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showDurationPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _inputBorderColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: const Color(0xFF6366F1),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$timeInMinutes minutes',
                        style: AppTextStyles.normal600(
                          fontSize: 14,
                          color: AppColors.text3Light,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
              border: Border.all(color: _inputBorderColor),
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
    );
  }

 Widget _buildSubjectSection() {
  final availableSubjects = _challengeSubjects;
  final selectedCount = _selectedSubjectIds.length;

  return Column(
    key: const ValueKey('subject-selection'),
    children: [
      Container(
        color: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  size: 15, color: AppColors.eLearningBtnColor1),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Select one or more subjects, then continue to set years and questions.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Expanded(
        child: availableSubjects.isEmpty
            ? _buildEmptySelectionState()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
                itemCount: availableSubjects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final subject = availableSubjects[index];
                  final isSelected = _selectedSubjectIds.contains(subject.id);
                  return _buildSelectableSubjectCard(subject, isSelected);
                },
              ),
      ),
      _ChallengeContinueBar(
        count: selectedCount,
        onTap: () {
          _prepareReviewSubjects();
          _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
      ),
    ],
  );
}

Widget _buildSubjectReviewSection() {
  final grouped = _groupSelectedSubjectRows();

  return SingleChildScrollView(
    key: const ValueKey('subject-review'),
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        if (grouped.isEmpty)
          _buildEmptyReviewState()
        else
          Column(
            children: grouped.entries.map((entry) {
              return _buildSubjectReviewCard(entry.key, entry.value);
            }).toList(),
          ),
      ],
    ),
  );
}

  Widget _buildDetailsActionBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
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
                  
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewActionBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF6366F1),
                      width: 1.2,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _submitChallenge(status: 'draft'),
                      borderRadius: BorderRadius.circular(12),
                      child: const Center(
                        child: Text(
                          'Save as Draft',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 48,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _submitChallenge(status: 'published'),
                      borderRadius: BorderRadius.circular(12),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1)
                                  .withValues(alpha: 0.28),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Publish',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectableSubjectCard(SubjectModel subject, bool isSelected) {
    final accent = subject.cardColor ?? _accentForSubject(subject);

    return GestureDetector(
      onTap: () => _toggleSubjectSelection(subject),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFCFD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accent : Colors.grey.shade200,
            width: isSelected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 6,
                child: Container(color: accent),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/${subject.subjectIcon ?? 'default'}.png',
                            width: 26,
                            height: 26,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.menu_book_rounded,
                              color: accent,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _titleCase(subject.name),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                fontFamily: 'Urbanist',
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isSelected ? 'Selected' : 'Tap to select',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _toggleSubjectSelection(subject),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected ? accent : Colors.grey.shade400,
                              width: 2,
                            ),
                            color: isSelected ? accent : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 18)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySelectionState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.category_outlined, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No subjects available',
            style: AppTextStyles.normal700(
              fontSize: 16,
              color: AppColors.text3Light,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'There are no subjects loaded for this exam type.',
            textAlign: TextAlign.center,
            style: AppTextStyles.normal400(
              fontSize: 13,
              color: AppColors.text7Light,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildSummaryTile(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.normal700(fontSize: 18, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.normal500(
              fontSize: 12,
              color: AppColors.text7Light,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ChallengeContinueBar({required int count, required VoidCallback onTap}) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: count > 0 ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            color: count > 0
                ? AppColors.eLearningBtnColor1
                : AppColors.eLearningBtnColor1.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              count > 0
                  ? 'Continue ($count subject${count > 1 ? 's' : ''})'
                  : 'Continue',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                fontFamily: 'Urbanist',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyReviewState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.fact_check_outlined, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No subjects selected',
            style: AppTextStyles.normal700(
              fontSize: 16,
              color: AppColors.text3Light,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Go back and select at least one subject to configure.',
            textAlign: TextAlign.center,
            style: AppTextStyles.normal400(
              fontSize: 13,
              color: AppColors.text7Light,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectReviewCard(String groupKey, List<SelectedSubject> rows) {
    final subject = rows.first;
    final subjectModel = _findSubjectById(subject.subjectId);
    final accent = subjectModel?.cardColor ??
        _accentForSubject(
          subjectModel ??
              SubjectModel(
                id: subject.subjectId,
                name: subject.subjectName,
              ),
        );

    return Column(
      children: rows.map((row) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent, width: 1.6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/${subject.icon == 'default' ? (subjectModel?.subjectIcon ?? 'default') : subject.icon}.png',
                        width: 26,
                        height: 26,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.menu_book_rounded,
                          color: accent,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _titleCase(subject.subjectName),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              fontFamily: 'Urbanist',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _yearSummaryForRow(row),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _removeSelectedRow(row),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1EA),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFFFB6B1C),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildYearChip(row, accent),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuestionChip(row),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildYearChip(SelectedSubject row, Color accent) {
    final label = _yearSummaryForRow(row);

    return GestureDetector(
      onTap: () => _showYearPickerForRow(row),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF1F1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 14,
              color: accent,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionChip(SelectedSubject row) {
    return GestureDetector(
      onTap: () async {
        final selected = await showModalBottomSheet<int>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Questions',
                        style: AppTextStyles.normal700(
                          fontSize: 18,
                          color: AppColors.text3Light,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 24,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: questionOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final count = questionOptions[index];
                        final isSelected = row.questionCount == count;
                        return Material(
                          color: isSelected
                              ? const Color(0xFF6366F1).withValues(alpha: 0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context, count),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF6366F1)
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$count questions',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? const Color(0xFF6366F1)
                                          : const Color(0xFF333333),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF6366F1),
                                    )
                                  else
                                    Icon(
                                      Icons.circle_outlined,
                                      color: Colors.grey.shade300,
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
            );
          },
        );

        if (selected != null) {
          _updateQuestionCount(row, selected);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5F7),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
            Icons.help_outline_rounded,
            size: 16,
            color: Colors.grey.shade600,
          ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '${row.questionCount} questions',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
   textCapitalization: TextCapitalization.sentences,
      inputFormatters: inputFormatters,
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
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _inputBorderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _inputBorderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _inputBorderColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[400]!, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _inputBorderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.grey[500],
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null
                    ? DateFormat('MMM dd, yyyy - hh:mm a').format(date)
                    : placeholder,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: date != null ? Colors.black87 : Colors.grey[400],
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
  final DateTime? startDate;
  final DateTime? endDate;
   final bool isEditing;

  const _CreationSuccessDialog({
    required this.title,
    required this.description,
    required this.subjects,
    this.startDate,
    this.endDate,
    this.isEditing = false,
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
                color: Colors.black.withValues(alpha: 0.2),
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
                   widget.isEditing ? 'Challenge Updated!' : 'Challenge Created!',
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
                    color: Colors.green.withValues(alpha: 0.4),
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
              color: Colors.black.withValues(alpha: 0.05),
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
                  'Ã¢â‚¬Â¢ ${_titleCase(subject.subjectName)} (${subject.year})',
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
            color: color.withValues(alpha: 0.1),
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
                  color: Colors.blue.shade400.withValues(alpha: 0.4),
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
  final int questionCount;
  final List<YearModel> selectedYears;

  SelectedSubject({
    required this.subjectName,
    required this.subjectId,
    required this.year,
    required this.examId,
    required this.icon,
    this.questionCount = 25,
    this.selectedYears = const [],
  });
  
  @override
  String toString() {
    return 'SelectedSubject{subject: $subjectName, subjectId: $subjectId, year: $year, examId: $examId, questionCount: $questionCount, selectedYears: $selectedYears}';
  }
}

// Convert a string to title case: capitalize first letter of every word
String _titleCase(String input) {
  if (input.isEmpty) return input;
  return input.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

class SubjectYearSelectionModal extends StatefulWidget {
  final List<SubjectModel> subjects;
  final Function(String subject, String subjectId, String year, String examId, String icon) onSubjectYearSelected;
  final VoidCallback? onClose;

  const SubjectYearSelectionModal({
    super.key,
    required this.subjects,
    required this.onSubjectYearSelected,
    this.onClose,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (showYears)
                        GestureDetector(
                          onTap: () => setState(() {
                            showYears = false;
                            _animationController.reverse();
                          }),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: Colors.black87,
                          ),
                        ),
                      if (showYears)
                        const SizedBox(width: 8),
                      Text(
                        showYears ? 'Select Year' : 'Select Subject',
                        style: AppTextStyles.normal600(
                          fontSize: 22,
                          color: AppColors.text3Light,
                        ),
                      ),
                    ],
                  ),
                  if (!showYears)
                    GestureDetector(
                      onTap: () {
                        widget.onClose?.call();
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        size: 24,
                        color: Colors.black87,
                      ),
                    ),
                ],
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
                      color: Colors.grey.withValues(alpha: 0.1),
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
                        _titleCase(subject.name),
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
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.event_busy_outlined,
                  color: Color(0xFF6366F1),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No years available',
                style: AppTextStyles.normal700(
                  fontSize: 18,
                  color: AppColors.text3Light,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This subject does not have any downloaded exam years yet. Download the subject first, then come back here.',
                textAlign: TextAlign.center,
                style: AppTextStyles.normal400(
                  fontSize: 14,
                  color: AppColors.text7Light,
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    showYears = false;
                    selectedSubject = null;
                  });
                  _animationController.reset();
                },
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back to subjects'),
              ),
            ],
          ),
        ),
      );
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
                      color: Colors.grey.withValues(alpha: 0.1),
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

/// Custom TextInputFormatter that capitalizes the first letter of each word (Title Case)
class _TitleCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.isEmpty) {
      return newValue;
    }

    final words = text.split(' ');
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) {
        return word;
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).toList();

    final capitalizedText = capitalizedWords.join(' ');

    return newValue.copyWith(
      text: capitalizedText,
      selection: TextSelection.fromPosition(
        TextPosition(offset: capitalizedText.length),
      ),
    );
  }
}
