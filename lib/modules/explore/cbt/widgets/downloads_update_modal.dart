import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/common/ads/ad_manager.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';
import 'package:linkschool/modules/model/explore/home/exam_model.dart';
import 'package:linkschool/modules/explore/e_library/test_screen.dart';
import 'package:linkschool/modules/explore/e_library/cbt_result_screen.dart';
import 'package:linkschool/modules/providers/explore/exam_provider.dart';
import 'package:linkschool/modules/services/database/download_service.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
import 'package:linkschool/modules/widgets/network_dialog.dart';

String _sentenceCase(String input) {
  if (input.isEmpty) return input;
  return input.toLowerCase().split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + (word.length > 1 ? word.substring(1) : '');
  }).join(' ');
}

// ═══════════════════════════════════════════════════════════════════
// SCREEN 1 — SubjectSelectionScreen
// Download subjects & checkbox-select them, then Continue
// ═══════════════════════════════════════════════════════════════════

class SubjectSelectionScreen extends StatefulWidget {
  const SubjectSelectionScreen({super.key});

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  final _downloadService = CbtDownloadService();

  // Set of selected subject IDs
  final Set<String> _selectedSubjectIds = {};

  // Download states keyed by subject.id
  final Map<String, DownloadState> _downloadStates = {};
  final Map<String, bool> _isDownloaded = {};
  bool _checkingDownloads = true;

  List<SubjectModel> get _subjects {
    final provider = Provider.of<CBTProvider>(context, listen: false);
    return provider.currentBoardSubjects;
  }

  String get _boardName {
    final provider = Provider.of<CBTProvider>(context, listen: false);
    return provider.selectedBoard?.shortName ?? 'Subjects';
  }

  String get _examTypeId {
    final provider = Provider.of<CBTProvider>(context, listen: false);
    return provider.selectedBoard?.id ?? '0';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDownloadedSubjects();
    });
  }

  Future<void> _checkDownloadedSubjects() async {
    for (final subject in _subjects) {
      final downloaded = await _downloadService.isSubjectDownloaded(
        examTypeId: _examTypeId,
        courseId: subject.id,
      );
      if (mounted) {
        setState(() => _isDownloaded[subject.id] = downloaded);
      }
    }
    if (mounted) setState(() => _checkingDownloads = false);
  }

  Future<void> _downloadSubject(SubjectModel subject) async {
    final canUseNetwork = await NetworkDialog.ensureOnline(context);
    if (!canUseNetwork || !mounted) return;

    setState(() {
      _downloadStates[subject.id] =
          const DownloadState(isDownloading: true, progress: 0.0);
    });

    await _downloadService.downloadSubject(
      examTypeId: _examTypeId,
      courseId: subject.id,
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            _downloadStates[subject.id] =
                DownloadState(isDownloading: true, progress: progress);
          });
        }
      },
      onComplete: () {
        if (mounted) {
          setState(() {
            _downloadStates[subject.id] = const DownloadState(
              isDownloading: false,
              isDownloaded: true,
              progress: 1.0,
            );
            _isDownloaded[subject.id] = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_sentenceCase(subject.name)} downloaded!'),
              backgroundColor:  AppColors.eLearningBtnColor1,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          Provider.of<CBTProvider>(context, listen: false).loadBoards();
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _downloadStates[subject.id] =
                const DownloadState(isDownloading: false);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download failed: $error'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  void _toggleSelection(SubjectModel subject) {
    if (!(_isDownloaded[subject.id] ?? false)) return;
    setState(() {
      if (_selectedSubjectIds.contains(subject.id)) {
        _selectedSubjectIds.remove(subject.id);
      } else {
        _selectedSubjectIds.add(subject.id);
      }
    });
  }

  void _onContinue(List<SubjectModel> allSubjects) {
    if (_selectedSubjectIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one subject to continue'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Build ordered list of selected subjects
    final selected = allSubjects
        .where((s) => _selectedSubjectIds.contains(s.id))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExamConfigScreen(selectedSubjects: selected),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<CBTProvider>(
        builder: (context, provider, _) {
          final subjects = provider.currentBoardSubjects;
          final boardName =
              provider.selectedBoard?.shortName ?? 'Subject Selection';
          final sortedSubjects = List<SubjectModel>.from(subjects)
            ..sort((a, b) =>
                _sentenceCase(a.name).compareTo(_sentenceCase(b.name)));

          return Column(
            children: [
              // ── Header ──────────────────────────────────────────────
              _buildHeader(boardName),

              // ── Hint ────────────────────────────────────────────────
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
                          'Download a subject first, then tap its checkbox to select it.',
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

              // ── Subject list ──────────────────────────────────────────
              Expanded(
                child: subjects.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
                        itemCount: sortedSubjects.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final subject = sortedSubjects[index];
                          return _SubjectDownloadCard(
                            subject: subject,
                            downloadState: _downloadStates[subject.id],
                            isDownloaded:
                                _isDownloaded[subject.id] ?? false,
                            isCheckingDownload: _checkingDownloads,
                            isSelected:
                                _selectedSubjectIds.contains(subject.id),
                            onDownload: () => _downloadSubject(subject),
                            onToggleSelect: () => _toggleSelection(subject),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),

      // ── Continue button ────────────────────────────────────────────
      bottomNavigationBar: Consumer<CBTProvider>(
        builder: (context, provider, _) {
          final subjects = provider.currentBoardSubjects;
          final count = _selectedSubjectIds.length;
          return _ContinueBar(
            count: count,
            onTap: () => _onContinue(subjects),
          );
        },
      ),
    );
  }

Widget _buildHeader(String boardName) {
  return Container(
    color: Colors.white,
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + 8,
      left: 8,
      right: 16,
      bottom: 14,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.eLearningBtnColor1.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.eLearningBtnColor1, size: 20),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${_sentenceCase(boardName.split(' ').first)} Subject Selection',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.eLearningBtnColor1,
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
            // ── Update button ──────────────────────────────────────
            GestureDetector(
              onTap: () => showUpdateSubjectsModal(
                context,
                _subjects,
                _examTypeId,
              ),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.eLearningBtnColor1.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.system_update_alt_rounded,
                  color: AppColors.eLearningBtnColor1,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STEP 1 OF 2',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.eLearningBtnColor1,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 2),
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration:  BoxDecoration(
              color: AppColors.eLearningBtnColor1.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.book_outlined,
                size: 56, color: AppColors.eLearningBtnColor1),
          ),
          const SizedBox(height: 20),
          const Text('No subjects available',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Please go back and select a board',
              style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// _SubjectDownloadCard — Screen 1 card with download + checkbox
// ═══════════════════════════════════════════════════════════════════

class _SubjectDownloadCard extends StatelessWidget {
  final SubjectModel subject;
  final DownloadState? downloadState;
  final bool isDownloaded;
  final bool isCheckingDownload;
  final bool isSelected;
  final VoidCallback onDownload;
  final VoidCallback onToggleSelect;

  const _SubjectDownloadCard({
    required this.subject,
    required this.downloadState,
    required this.isDownloaded,
    required this.isCheckingDownload,
    required this.isSelected,
    required this.onDownload,
    required this.onToggleSelect,
  });

  static const List<Color> _accentColors = [
    Color(0xFF0F766E), // teal
    Color(0xFF2563EB), // blue
    Color(0xFFDC2626), // red
    Color(0xFF16A34A), // green
    Color(0xFFB45309), // amber
    Color(0xFF4F46E5), // indigo
  ];

  int _stableHash(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  Color _accentForSubject(SubjectModel subject) {
    final key = _stableHash(subject.id.isNotEmpty ? subject.id : subject.name);
    return _accentColors[key % _accentColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDownloading = downloadState?.isDownloading ?? false;
    final progress = downloadState?.progress ?? 0.0;
    final accent = _accentForSubject(subject);

    return GestureDetector(
      onTap: isDownloaded ? onToggleSelect : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFCFD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0F766E)
                : Colors.grey.shade200,
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
                      // Subject icon
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

                      // Name + status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _sentenceCase(subject.name),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                fontFamily: 'Urbanist',
                              ),
                            ),
                            const SizedBox(height: 3),
                            if (isCheckingDownload)
                              Text('Checking...',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade400))
                            else if (isDownloaded)
                              Row(
                                children: [
                                  Icon(Icons.wifi_off_rounded,
                                      size: 13, color: Color(0xFF0F766E),),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Available offline',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF0F766E),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            else if (isDownloading)
                              Text('Downloading...',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500))
                            else
                              Text('Tap to download',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500)),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Right action area
                      if (isCheckingDownload)
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else if (isDownloading)
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 3,
                                color: accent,
                                backgroundColor: Colors.grey.shade200,
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (isDownloaded)
                        // Checkbox
                        GestureDetector(
                          onTap: onToggleSelect,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? Color(0xFF0F766E)
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                              color:
                                  isSelected ? Color(0xFF0F766E) : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 18)
                                : null,
                          ),
                        )
                      else
                        // Download button
                        GestureDetector(
                          onTap: onDownload,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Icon(
                              Icons.download_rounded,
                              color: Color(0xFF555555),
                              size: 22,
                            ),
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
}

// ═══════════════════════════════════════════════════════════════════
// SCREEN 2 — ExamConfigScreen
// Shows selected subjects, year picker per subject + time/duration
// ═══════════════════════════════════════════════════════════════════

class ExamConfigScreen extends StatefulWidget {
  final List<SubjectModel> selectedSubjects;

  const ExamConfigScreen({super.key, required this.selectedSubjects});

  @override
  State<ExamConfigScreen> createState() => _ExamConfigScreenState();
}

class _ExamConfigScreenState extends State<ExamConfigScreen> {
  // subjectId → chosen year entry
  final Map<String, _SelectedEntry> _yearSelections = {};

  int timeInMinutes = 60;
  int questionLimit = 40;

  final List<int> timeOptions = [60, 45, 40, 35, 30, 25, 20, 10];
  final List<int> questionOptions = [60, 55, 50, 45, 40, 35, 30, 25, 10];

  Future<void> _showYearPicker(SubjectModel subject) async {
    final years = subject.years ?? [];
    if (years.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No years available for this subject.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final sorted = List<YearModel>.from(years)
      ..sort((a, b) => b.year.compareTo(a.year));

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _YearPickerSheet(
        subjectName: _sentenceCase(subject.name),
        years: sorted,
        currentSelection: _yearSelections[subject.id],
        onYearSelected: (entry) {
          setState(() => _yearSelections[subject.id] = entry);
          Navigator.pop(context);
        },
      ),
    );
  }

  bool get _allYearsSelected {
    return widget.selectedSubjects
        .every((s) => _yearSelections.containsKey(s.id));
  }

  void _startTest() {
    if (!_allYearsSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a year for each subject'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final examIds =
        widget.selectedSubjects.map((s) => _yearSelections[s.id]!.examId).toList();
    final subjectNames =
        widget.selectedSubjects.map((s) => _sentenceCase(s.name)).toList();
    final years =
        widget.selectedSubjects.map((s) => _yearSelections[s.id]!.year).toList();
    final totalSeconds = timeInMinutes * 60 * widget.selectedSubjects.length;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiSubjectTestScreen(
          examIds: examIds,
          subjects: subjectNames,
          years: years,
          totalDurationInSeconds: totalSeconds,
          questionLimit: questionLimit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          _buildHeader(),

          // ── Settings bar ─────────────────────────────────────────
          _buildSettingsBar(),

          // ── Hint ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
            child: Row(
              children: [
                const Icon(Icons.touch_app_outlined,
                    size: 15, color: AppColors.eLearningBtnColor1),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Tap a subject card to choose an exam year.',
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

          // ── Subject cards ─────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
              itemCount: widget.selectedSubjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final subject = widget.selectedSubjects[index];
                return _ExamConfigSubjectCard(
                  subject: subject,
                  selection: _yearSelections[subject.id],
                  onPickYear: () => _showYearPicker(subject),
                  onClearYear: () =>
                      setState(() => _yearSelections.remove(subject.id)),
                );
              },
            ),
          ),
        ],
      ),

      // ── Start button ───────────────────────────────────────────────
      bottomNavigationBar: _buildStartBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 16,
        bottom: 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration:  BoxDecoration(
                    color: AppColors.eLearningBtnColor1.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: AppColors.eLearningBtnColor1, size: 20),
                ),
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Text(
                  'Exam Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.eLearningBtnColor1,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STEP 2 OF 2',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.eLearningBtnColor1,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 2),
                // Text(
                //   'Select exam duration and question limit ',
                //   style: TextStyle(
                //     fontSize: 15,
                //     fontWeight: FontWeight.w600,
                //     color: AppColors.eLearningBtnColor1,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 4, 0, 14),
      child: Row(
        children: [
          Expanded(
            child: _SettingDropdown<int>(
              icon: Icons.timer_outlined,
              label: 'Time :',
              value: timeInMinutes,
              items: timeOptions,
              itemLabel: (v) => '${v}min',
              onChanged: (v) => setState(() => timeInMinutes = v),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SettingDropdown<int>(
              icon: Icons.quiz_outlined,
              label: 'Questions :',
              value: questionLimit,
              items: questionOptions,
              itemLabel: (v) => '$v Qs',
              onChanged: (v) => setState(() => questionLimit = v),
            ),
          ),
             const SizedBox(width: 5),
        ],
      ),
    );
  }

  Widget _buildStartBar() {
    final ready = _allYearsSelected && widget.selectedSubjects.isNotEmpty;
    final count = widget.selectedSubjects.length;
    final total = timeInMinutes * count;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary row
          if (ready)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SummaryChip(
                      icon: Icons.book_outlined,
                      label: '$count subject${count > 1 ? 's' : ''}'),
                  const SizedBox(width: 10),
                  _SummaryChip(
                      icon: Icons.timer_outlined, label: '${total}min total'),
                  const SizedBox(width: 10),
                  _SummaryChip(
                      icon: Icons.quiz_outlined, label: '$questionLimit Qs each'),
                ],
              ),
            ),
          GestureDetector(
            onTap: ready ? _startTest : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 54,
              decoration: BoxDecoration(
                color: ready
                    ?  AppColors.eLearningBtnColor1
                    :  AppColors.eLearningBtnColor1.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  ready
                      ? 'START TEST'
                      : 'Pick a year for each subject',
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
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// _ExamConfigSubjectCard — Screen 2 card with year selection
// ═══════════════════════════════════════════════════════════════════

class _ExamConfigSubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final _SelectedEntry? selection;
  final VoidCallback onPickYear;
  final VoidCallback onClearYear;

  const _ExamConfigSubjectCard({
    required this.subject,
    required this.selection,
    required this.onPickYear,
    required this.onClearYear,
  });

  static const List<Color> _accentColors = [
    Color(0xFF0F766E), // teal
    Color(0xFF2563EB), // blue
    Color(0xFFDC2626), // red
    Color(0xFF16A34A), // green
    Color(0xFFB45309), // amber
    Color(0xFF4F46E5), // indigo
  ];

  int _stableHash(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  Color _accentForSubject(SubjectModel subject) {
    final key = _stableHash(subject.id.isNotEmpty ? subject.id : subject.name);
    return _accentColors[key % _accentColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final hasYear = selection != null;
    final accent = _accentForSubject(subject);

    return GestureDetector(
      onTap: onPickYear,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFCFD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasYear ? accent : Colors.grey.shade200,
            width: hasYear ? 1.4 : 1,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Main row
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          // Icon
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

                          // Name + year status
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _sentenceCase(subject.name),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                    fontFamily: 'Urbanist',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                hasYear
                                    ? Row(
                                        children: [
                                          Icon(Icons.check_circle,
                                              size: 14, color: accent),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Year ${selection!.year} selected',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: accent,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Icon(Icons.radio_button_unchecked,
                                              size: 14,
                                              color: Colors.grey.shade400),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Tap to select a year',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),

                          // Right action: clear or chevron
                          if (hasYear)
                            GestureDetector(
                              onTap: onClearYear,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 16, color: Colors.grey),
                              ),
                            )
                          else
                            const Icon(Icons.chevron_right,
                                color: Colors.grey, size: 22),
                        ],
                      ),
                    ),

                    // Year badge row (when selected)
                    if (hasYear) ...[
                      Container(height: 1, color: Colors.grey.shade100),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_month_rounded,
                                      size: 13, color: accent),
                                  const SizedBox(width: 5),
                                  Text(
                                    selection!.year ==
                                            DateTime.now().year.toString()
                                        ? '${selection!.year} (Simulation)'
                                        : selection!.year,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: onPickYear,
                              child: Text(
                                'Change',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// _YearPickerSheet — bottom sheet for choosing a year (Screen 2)
// ═══════════════════════════════════════════════════════════════════

class _YearPickerSheet extends StatelessWidget {
  final String subjectName;
  final List<YearModel> years;
  final _SelectedEntry? currentSelection;
  final void Function(_SelectedEntry) onYearSelected;

  const _YearPickerSheet({
    required this.subjectName,
    required this.years,
    required this.currentSelection,
    required this.onYearSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subjectName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.eLearningBtnColor1,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Select a year to practice',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        size: 18, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Container(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 8),

          // Year list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: years.length,
              itemBuilder: (context, index) {
                final year = years[index];
                final isCurrentYear =
                    year.year == DateTime.now().year.toString();
                final isSelected = currentSelection?.examId == year.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isSelected
                        ?  AppColors.eLearningBtnColor1.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        onYearSelected(_SelectedEntry(
                          subjectName: subjectName,
                          subjectId: '',
                          year: year.year,
                          examId: year.id,
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ?  AppColors.eLearningBtnColor1
                                : Colors.grey.shade200,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ?  AppColors.eLearningBtnColor1
                                        .withValues(alpha: 0.15)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.calendar_month_rounded,
                                  size: 18,
                                  color: isSelected
                                      ?  AppColors.eLearningBtnColor1
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isCurrentYear
                                        ? '${year.year}  (Simulation)'
                                        : year.year,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ?  AppColors.eLearningBtnColor1
                                          : const Color(0xFF333333),
                                    ),
                                  ),
                                  if (isCurrentYear)
                                    Text(
                                      'Practice with current-style questions',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: AppColors.eLearningBtnColor1, size: 22)
                            else
                              Icon(Icons.radio_button_unchecked,
                                  color: Colors.grey.shade300, size: 22),
                          ],
                        ),
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
  }
}

// ═══════════════════════════════════════════════════════════════════
// _SummaryChip — small pill shown in the start bar
// ═══════════════════════════════════════════════════════════════════

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:  AppColors.eLearningBtnColor1.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color:  AppColors.eLearningBtnColor1),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.eLearningBtnColor1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// _SettingDropdown
// ═══════════════════════════════════════════════════════════════════

class _SettingDropdown<T> extends StatelessWidget {
  final IconData icon;
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T) onChanged;

  const _SettingDropdown({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color:  Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color:  AppColors.eLearningBtnColor1.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color:  AppColors.eLearningBtnColor1),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.eLearningBtnColor1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              isDense: true,
              underline: const SizedBox(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:Colors.black,
              ),
              items: items
                  .map((item) => DropdownMenuItem<T>(
                        value: item,
                        child: Text(itemLabel(item)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// _SelectedEntry — data model for a subject+year selection
// ═══════════════════════════════════════════════════════════════════

class _SelectedEntry {
  final String subjectName;
  final String subjectId;
  final String year;
  final String examId;

  const _SelectedEntry({
    required this.subjectName,
    required this.subjectId,
    required this.year,
    required this.examId,
  });
}

// ═══════════════════════════════════════════════════════════════════
// _ContinueBar — shared bottom bar used by Screen 1
// ═══════════════════════════════════════════════════════════════════

class _ContinueBar extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _ContinueBar({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
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
          duration:  Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            color: count > 0
                ?  AppColors.eLearningBtnColor1
                :  AppColors.eLearningBtnColor1.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              count > 0
                  ? 'CONTINUE ($count subject${count > 1 ? 's' : ''})'
                  : 'CONTINUE',
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
}

// ═══════════════════════════════════════════════════════════════════
// showUpdateSubjectsModal — Shows modal to update subjects
// ═══════════════════════════════════════════════════════════════════

Future<void> showUpdateSubjectsModal(
  BuildContext context,
  List<SubjectModel> subjects,
  String examTypeId,
) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _UpdateSubjectsSheet(
      subjects: subjects,
      examTypeId: examTypeId,
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════
// _UpdateSubjectsSheet — Bottom sheet for updating subjects
// ═══════════════════════════════════════════════════════════════════

class _UpdateSubjectsSheet extends StatefulWidget {
  final List<SubjectModel> subjects;
  final String examTypeId;

  const _UpdateSubjectsSheet({
    required this.subjects,
    required this.examTypeId,
  });

  @override
  State<_UpdateSubjectsSheet> createState() => _UpdateSubjectsSheetState();
}

class _UpdateSubjectsSheetState extends State<_UpdateSubjectsSheet> {
  final _downloadService = CbtDownloadService();
  final Map<String, DownloadState> _downloadStates = {};
  final List<SubjectModel> _downloadedSubjects = [];
  bool _loadingDownloaded = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedSubjects();
  }

  Future<void> _loadDownloadedSubjects() async {
    _downloadedSubjects.clear();
    for (final subject in widget.subjects) {
      final downloaded = await _downloadService.isSubjectDownloaded(
        examTypeId: widget.examTypeId,
        courseId: subject.id,
      );
      if (downloaded) _downloadedSubjects.add(subject);
    }
    if (!mounted) return;
    setState(() => _loadingDownloaded = false);
  }

  Future<void> _refreshSubject(SubjectModel subject) async {
    if (_downloadStates[subject.id]?.isDownloading ?? false) return;

    final canUseNetwork = await NetworkDialog.ensureOnline(context);
    if (!canUseNetwork || !mounted) return;

    setState(() {
      _downloadStates[subject.id] =
          const DownloadState(isDownloading: true, progress: 0.0);
    });

    await _downloadService.clearSubjectData(
      examTypeId: widget.examTypeId,
      courseId: subject.id,
    );

    await _downloadService.downloadSubject(
      examTypeId: widget.examTypeId,
      courseId: subject.id,
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            _downloadStates[subject.id] =
                DownloadState(isDownloading: true, progress: progress);
          });
        }
      },
      onComplete: () {
        if (!mounted) return;
        setState(() {
          _downloadStates[subject.id] = const DownloadState(
            isDownloading: false,
            isDownloaded: true,
            progress: 1.0,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_sentenceCase(subject.name)} updated!'),
            backgroundColor: AppColors.eLearningBtnColor1,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Provider.of<CBTProvider>(context, listen: false).loadBoards();
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _downloadStates[subject.id] =
              const DownloadState(isDownloading: false);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $error'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Update Subjects',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.eLearningBtnColor1,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Refresh your downloaded subjects',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        size: 18, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Container(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 8),

          // Subject list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: _loadingDownloaded
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        color: AppColors.eLearningBtnColor1,
                      ),
                    ),
                  )
                : _downloadedSubjects.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No downloaded subjects yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: _downloadedSubjects.length,
                    itemBuilder: (context, index) {
                      final subject = _downloadedSubjects[index];
                      final downloadState = _downloadStates[subject.id];
                      final isDownloading =
                          downloadState?.isDownloading ?? false;
                      final progress = downloadState?.progress ?? 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
                            color: Colors.grey.shade50,
                          ),
                          child: Row(
                            children: [
                              
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _sentenceCase(subject.name),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isDownloading
                                          ? 'Updating... ${(progress * 100).toStringAsFixed(0)}%'
                                          : 'Your downloaded version',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: isDownloading
                                    ? null
                                    : () => _refreshSubject(subject),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: isDownloading
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            value:
                                                progress > 0 ? progress : null,
                                            strokeWidth: 2.2,
                                            color: AppColors.eLearningBtnColor1,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.refresh_rounded,
                                          size: 18,
                                          color: AppColors.eLearningBtnColor1,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MultiSubjectTestScreen — unchanged from Document 2
// ═══════════════════════════════════════════════════════════════════

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
  State<MultiSubjectTestScreen> createState() =>
      _MultiSubjectTestScreenState();
}

class _MultiSubjectTestScreenState extends State<MultiSubjectTestScreen>
    with WidgetsBindingObserver {
  int currentExamIndex = 0;
  late int remainingSeconds;
  Map<String, Map<int, int>> allAnswers = {};
  Map<String, List<QuestionModel>> allQuestions = {};
  Map<String, String> subjectNames = {};
  Map<String, String> subjectYears = {};
  bool _isNavigatingAway = false;
  bool _shouldShowAdOnResume = false;
  bool _allowAppOpenAds = false;

  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    remainingSeconds = widget.totalDurationInSeconds;
    for (int i = 0; i < widget.examIds.length; i++) {
      subjectNames[widget.examIds[i]] = widget.subjects[i];
      subjectYears[widget.examIds[i]] = widget.years[i];
    }
    _initAppOpenAdEligibility();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _allowAppOpenAds) _loadAppOpenAd();
    });
  }

  Future<void> _initAppOpenAdEligibility() async {
    final allowed = await AdManager.instance.shouldShowCbtOpenAds(context);
    if (!mounted) return;
    setState(() {
      _allowAppOpenAds = allowed;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused && !_isNavigatingAway) {
      _shouldShowAdOnResume = true;
    } else if (state == AppLifecycleState.resumed && _shouldShowAdOnResume) {
      if (_allowAppOpenAds) {
        _showAppOpenAd();
      }
      _shouldShowAdOnResume = false;
    }
  }

  void _loadAppOpenAd() {
    if (!_allowAppOpenAds) return;
    AppOpenAd.load(
      adUnitId: EnvConfig.cbtAdsOpenApiKey,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          if (mounted) setState(() => _isAppOpenAdLoaded = true);
        },
        onAdFailedToLoad: (_) {
          if (mounted) setState(() => _isAppOpenAdLoaded = false);
        },
      ),
    );
  }

  void _showAppOpenAd() {
    if (!_allowAppOpenAds) return;
    if (!_isAppOpenAdLoaded || _appOpenAd == null) return;
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenAdLoaded = false;
        _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenAdLoaded = false;
        _loadAppOpenAd();
      },
    );
    _appOpenAd!.show();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appOpenAd?.dispose();
    super.dispose();
  }

  void _loadNextExam() {
    if (currentExamIndex < widget.examIds.length - 1) {
      setState(() => currentExamIndex++);
    } else {
      _showFinalResults();
    }
  }

  void _showFinalResults() {
    _isNavigatingAway = true;
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
          allSubjectsData: widget.examIds.map((examId) => {
                'questions': allQuestions[examId] ?? [],
                'userAnswers': allAnswers[examId] ?? {},
                'subject': subjectNames[examId] ?? '',
                'year':
                    int.tryParse(subjectYears[examId] ?? '') ??
                        DateTime.now().year,
                'examId': examId,
              }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TestScreen(
      key: ValueKey(widget.examIds[currentExamIndex]),
      examTypeId: widget.examIds[currentExamIndex],
      subject: widget.subjects[currentExamIndex],
      year: int.tryParse(widget.years[currentExamIndex]),
      calledFrom: 'multi-subject',
      totalDurationInSeconds: remainingSeconds,
      questionLimit: widget.questionLimit,
      isLastInMultiSubject: currentExamIndex == widget.examIds.length - 1,
      currentExamIndex: currentExamIndex,
      totalExams: widget.examIds.length,
      allAnswers: allAnswers,
      allQuestions: allQuestions,
      onExamComplete: (userAnswers, remainingTime) {
        final currentExamId = widget.examIds[currentExamIndex];
        allAnswers[currentExamId] = Map<int, int>.from(userAnswers);
        final provider = Provider.of<ExamProvider>(context, listen: false);
        allQuestions[currentExamId] =
            List<QuestionModel>.from(provider.questions);
        remainingSeconds = remainingTime;
        provider.reset();
        _loadNextExam();
      },
    );
  }
}
