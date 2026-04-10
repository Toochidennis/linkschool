import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/cbt/cbt_games/game_instruction.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';
import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
import 'package:linkschool/modules/services/database/download_service.dart';
import 'package:linkschool/modules/services/explore/offline_game_question_service.dart';
import 'package:linkschool/modules/widgets/network_dialog.dart';
import 'package:provider/provider.dart';

String _sentenceCase(String input) {
  if (input.isEmpty) return input;
  return input.toLowerCase().split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + (word.length > 1 ? word.substring(1) : '');
  }).join(' ');
}

class GameSubjectDownloadScreen extends StatefulWidget {
  final List<SubjectModel> subjects;
  final int examTypeId;

  const GameSubjectDownloadScreen({
    super.key,
    required this.subjects,
    required this.examTypeId,
  });

  @override
  State<GameSubjectDownloadScreen> createState() =>
      _GameSubjectDownloadScreenState();
}

class _GameSubjectDownloadScreenState extends State<GameSubjectDownloadScreen> {
  final CbtDownloadService _downloadService = CbtDownloadService();
  static const Color _primaryAccent = AppColors.eLearningBtnColor1;
  static const Color _iconBadgeBackground = Color(0xFFF1F6FB);
  static const Color _iconBadgeBorder = Color(0xFFDCE7F2);

  final Map<String, DownloadState> _downloadStates = {};
  final Map<String, bool> _isDownloaded = {};
  String? _selectedSubjectId;
  bool _checkingDownloads = true;

  List<SubjectModel> get _sortedSubjects {
    final subjects = List<SubjectModel>.from(widget.subjects);
    subjects
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return subjects;
  }

  String get _examTypeIdAsString => widget.examTypeId.toString();

  Color _iconTintForSubject(SubjectModel subject) {
    const palette = <Color>[
      Color(0xFF49657D),
      Color(0xFF345D7A),
      Color(0xFF4F5D95),
      Color(0xFF2E6B6A),
      Color(0xFF6B5C8C),
    ];
    return palette[subject.name.hashCode.abs() % palette.length];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDownloadedSubjects();
    });
  }

  String? _firstDownloadedSubjectId(Iterable<String> downloadedIds) {
    for (final subject in _sortedSubjects) {
      if (downloadedIds.contains(subject.id)) {
        return subject.id;
      }
    }
    return null;
  }

  Future<void> _checkDownloadedSubjects() async {
    final downloadedIds = await _downloadService.getDownloadedCourseIds(
      examTypeId: _examTypeIdAsString,
      courseIds: widget.subjects.map((subject) => subject.id),
    );

    if (!mounted) return;

    final autoSelectedSubjectId = _firstDownloadedSubjectId(downloadedIds);

    setState(() {
      for (final subject in widget.subjects) {
        _isDownloaded[subject.id] = downloadedIds.contains(subject.id);
      }
      if (_selectedSubjectId == null ||
          !downloadedIds.contains(_selectedSubjectId)) {
        _selectedSubjectId = autoSelectedSubjectId;
      }
      _checkingDownloads = false;
    });
  }

  Future<void> _downloadSubject(SubjectModel subject) async {
    final canUseNetwork = await NetworkDialog.ensureOnline(context);
    if (!canUseNetwork || !mounted) return;

    setState(() {
      _downloadStates[subject.id] =
          const DownloadState(isDownloading: true, progress: 0);
    });

    await _downloadService.downloadSubject(
      examTypeId: _examTypeIdAsString,
      courseId: subject.id,
      onProgress: (progress) {
        if (!mounted) return;
        setState(() {
          _downloadStates[subject.id] = DownloadState(
            isDownloading: true,
            progress: progress,
          );
        });
      },
      onComplete: () {
        if (!mounted) return;
        setState(() {
          _downloadStates[subject.id] = const DownloadState(
            isDownloading: false,
            isDownloaded: true,
            progress: 1,
          );
          _isDownloaded[subject.id] = true;
          _selectedSubjectId = subject.id;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_sentenceCase(subject.name)} downloaded!'),
            backgroundColor: AppColors.eLearningBtnColor1,
            behavior: SnackBarBehavior.floating,
          ),
        );

        context.read<CBTProvider>().loadBoards();
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _downloadStates[subject.id] = const DownloadState();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $error'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _selectSubject(SubjectModel subject) {
    if (!(_isDownloaded[subject.id] ?? false)) return;
    setState(() {
      _selectedSubjectId = subject.id;
    });
  }

  void _continueToGame() {
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download and select a subject to continue'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final subject = widget.subjects.firstWhere(
      (item) => item.id == _selectedSubjectId,
      orElse: () => SubjectModel(id: '', name: '', years: []),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameInstructionsScreen(
          subject: subject.name,
          courseId: int.tryParse(subject.id) ?? 0,
          examTypeId: widget.examTypeId,
          questionLimit: OfflineGameQuestionService.defaultQuestionLimit,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Choose Subject',
              style: AppTextStyles.normal600(
                fontSize: 19,
                color: AppColors.text4Light,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTile(SubjectModel subject) {
    final downloadState = _downloadStates[subject.id] ?? const DownloadState();
    final isDownloading = downloadState.isDownloading;
    final isDownloaded = _isDownloaded[subject.id] ?? false;
    final isSelected = _selectedSubjectId == subject.id;
    final iconName = subject.subjectIcon ?? 'default';
    final iconTint = _iconTintForSubject(subject);
    final cardBackground = isSelected
        ? _primaryAccent.withValues(alpha: 0.10)
        : isDownloaded
            ? const Color(0xFFFFFFFF)
            : Colors.white;

    return GestureDetector(
      onTap: () => _selectSubject(subject),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(16),
          border:
              isSelected ? Border.all(color: _primaryAccent, width: 1.6) : null,
          boxShadow: [
            BoxShadow(
              color: (isSelected ? _primaryAccent : Colors.black)
                  .withValues(alpha: isSelected ? 0.16 : 0.04),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _iconBadgeBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _iconBadgeBorder),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons/$iconName.png',
                  width: 24,
                  height: 24,
                  color: iconTint,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.subject,
                    color: iconTint,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _sentenceCase(subject.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.normal600(
                      fontSize: 15,
                      color: AppColors.text4Light,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _primaryAccent
                              : isDownloaded
                                  ? _primaryAccent.withValues(alpha: 0.10)
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          isSelected
                              ? 'Selected'
                              : isDownloaded
                                  ? 'Ready'
                                  : 'Not downloaded',
                          style: AppTextStyles.normal600(
                            fontSize: 11,
                            color: isSelected
                                ? Colors.white
                                : isDownloaded
                                    ? _primaryAccent
                                    : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      if (isDownloading) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${(downloadState.progress * 100).round()}%',
                          style: AppTextStyles.normal600(
                            fontSize: 11,
                            color: _primaryAccent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (isDownloading)
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  value: downloadState.progress == 0
                      ? null
                      : downloadState.progress,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(_primaryAccent),
                ),
              )
            else if (isDownloaded)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? _primaryAccent
                      : _primaryAccent.withValues(alpha: 0.10),
                  border: Border.all(
                    color: isSelected
                        ? _primaryAccent
                        : _primaryAccent.withValues(alpha: 0.18),
                    width: 1.4,
                  ),
                ),
                child: Icon(
                  isSelected ? Icons.check : Icons.radio_button_unchecked,
                  size: 16,
                  color: isSelected ? Colors.white : _primaryAccent,
                ),
              )
            else
              SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: () => _downloadSubject(subject),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Download',
                    style: AppTextStyles.normal600(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _checkingDownloads
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      children: _sortedSubjects
                          .map(_buildSubjectTile)
                          .toList(growable: false),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _continueToGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.eLearningBtnColor1,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Continue to Game',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
