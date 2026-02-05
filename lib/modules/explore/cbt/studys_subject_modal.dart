import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/cbt/cbt_study_screen.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';
import 'package:linkschool/modules/services/cbt_subscription_service.dart';
import 'package:linkschool/modules/services/firebase_auth_service.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/explore/e_library/widgets/subscription_enforcement_dialog.dart';
import 'package:linkschool/modules/common/cbt_settings_helper.dart';
import 'package:linkschool/modules/providers/explore/subject_topic_provider.dart';
import 'package:linkschool/modules/model/explore/study/topic_model.dart';
import 'package:provider/provider.dart';

class StudySubjectSelectionModal extends StatefulWidget {
  final List<SubjectModel> subjects;
  final int examTypeId;

  const StudySubjectSelectionModal({
    super.key,
    required this.subjects,
    required this.examTypeId,
  });

  @override
  State<StudySubjectSelectionModal> createState() =>
      _StudySubjectSelectionModalState();
}

class _StudySubjectSelectionModalState
    extends State<StudySubjectSelectionModal> {
  String? _selectedSubject;
  List<int> _selectedTopicIds = [];
  List<String> _selectedTopicNames = [];
  bool _showTopics = false;
  bool _isTransitioning = false;
  final Set<int> _expandedSyllabusIds = {};

  // Search state
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final _subscriptionService = CbtSubscriptionService();
  final _authService = FirebaseAuthService();

  @override
  void dispose() {
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

  // Deterministic color selection for subject ids
  Color _colorForId(String id) {
    final List<Color> fallbackColors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFEC4899), // Pink
      const Color(0xFFEF4444), // Red
      const Color(0xFF14B8A6), // Teal
      const Color(0xFFF97316), // Orange
    ];

    final rand = id.hashCode.abs();
    return fallbackColors[rand % fallbackColors.length];
  }

  Future<void> _onSubjectSelected(String subjectId) async {
    setState(() {
      _selectedSubject = subjectId;
      _isTransitioning = true;
      // Clear search when subject is selected
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });

    // Fetch topics from API
    final topicsProvider =
        Provider.of<SubjectTopicsProvider>(context, listen: false);

    // Get courseId from subject
    final subject = widget.subjects.firstWhere((s) => s.id == subjectId);
    final courseId = int.tryParse(subject.id) ?? 0;

    // Use the exam type ID passed from the dashboard
    await topicsProvider.loadTopics(
      courseId: courseId,
      examTypeId: widget.examTypeId,
    );

    // Fade out and then show topics
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showTopics = true;
          _isTransitioning = false;
        });
      }
    });
  }

  // Convert a string to title case: capitalize first letter of every word
  String _titleCase(String input) {
    if (input.isEmpty) return input;
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  void _onTopicSelected(Topic topic) {
    setState(() {
      if (_selectedTopicIds.contains(topic.topicId)) {
        _selectedTopicIds.remove(topic.topicId);
        _selectedTopicNames.remove(topic.topicName);
      } else {
        _selectedTopicIds.add(topic.topicId);
        _selectedTopicNames.add(topic.topicName);
      }
    });
  }

  void _toggleSyllabus(int syllabusId) {
    setState(() {
      if (_expandedSyllabusIds.contains(syllabusId)) {
        _expandedSyllabusIds.remove(syllabusId);
      } else {
        _expandedSyllabusIds.add(syllabusId);
      }
    });
  }

  // Check if all topics in a syllabus are selected
  bool _areAllTopicsSelected(List<Topic> topics) {
    if (topics.isEmpty) return false;
    return topics.every((topic) => _selectedTopicIds.contains(topic.topicId));
  }

  // Check if some (but not all) topics in a syllabus are selected
  bool _areSomeTopicsSelected(List<Topic> topics) {
    if (topics.isEmpty) return false;
    final selectedCount = topics
        .where((topic) => _selectedTopicIds.contains(topic.topicId))
        .length;
    return selectedCount > 0 && selectedCount < topics.length;
  }

  // Toggle all topics in a syllabus
  void _toggleAllTopicsInSyllabus(List<Topic> topics) {
    setState(() {
      final allSelected = _areAllTopicsSelected(topics);
      if (allSelected) {
        // Deselect all topics in this syllabus
        for (final topic in topics) {
          _selectedTopicIds.remove(topic.topicId);
          _selectedTopicNames.remove(topic.topicName);
        }
      } else {
        // Select all topics in this syllabus
        for (final topic in topics) {
          if (!_selectedTopicIds.contains(topic.topicId)) {
            _selectedTopicIds.add(topic.topicId);
            _selectedTopicNames.add(topic.topicName);
          }
        }
      }
    });
  }

  Future<void> _onContinue() async {
    // if (_selectedTopicIds.isEmpty) return;

    // // ⚡ Study Module: Check subscription with free trial tracking
    // final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
    // final hasUserPaid = userProvider.hasPaid;
    // final canTakeTest = await _subscriptionService.canTakeTest();
    // final remainingTests = await _subscriptionService.getRemainingFreeTests();

    // print('\n📚 Study Module Access Check:');
    // print('   - Backend says paid: $hasUserPaid');
    // print('   - Local says can take test: $canTakeTest');
    // print('   - Remaining free tests: $remainingTests');

    // // If backend confirms payment, allow access
    // if (hasUserPaid) {
    //   print('   ✅ User has paid (verified from backend) - starting study');
    //   _proceedWithStudy();
    //   return;
    // }

    // // If not paid, show prompt (hard if trial expired)
    // final trialExpired = await _subscriptionService.isTrialExpired();
    // final settings = await CbtSettingsHelper.getSettings();
    // if (!mounted) return;

    // if (!canTakeTest || trialExpired) {
    //   print('   ❌ Study access denied - showing enforcement dialog');
    //   final allowProceed = await showDialog<bool>(
    //     context: context,
    //     barrierDismissible: true,
    //     builder: (context) => SubscriptionEnforcementDialog(
    //       isHardBlock: true,
    //       remainingTests: remainingTests,
    //       amount: settings.amount,
    //       discountRate: settings.discountRate,
    //       onSubscribed: () async {
    //         print('✅ User subscribed from Study module');
    //         await userProvider.refreshCurrentUser();
    //         if (mounted) {
    //           setState(() {});
    //         }
    //       },
    //     ),
    //   );
    //   if (allowProceed == true) {
    //     _proceedWithStudy();
    //   }
    //   return;
    // }

    // // Within trial: show soft prompt and allow proceed
    // final allowProceed = await showDialog<bool>(
    //   context: context,
    //   barrierDismissible: true,
    //   builder: (context) => SubscriptionEnforcementDialog(
    //     isHardBlock: false,
    //     remainingTests: remainingTests,
    //     amount: settings.amount,
    //     discountRate: settings.discountRate,
    //     onSubscribed: () async {
    //       print('✅ User subscribed from Study module');
    //       await userProvider.refreshCurrentUser();
    //       if (mounted) {
    //         setState(() {});
    //       }
    //     },
    //   ),
    // );

    // if (allowProceed == true) {
    //   print('   ✅ User can access study (within free limit)');
      _proceedWithStudy();
    
  }

  void _proceedWithStudy() {
    final subject = widget.subjects.firstWhere(
      (s) => s.id == _selectedSubject,
      orElse: () => SubjectModel(
          id: _selectedSubject ?? '', name: _selectedSubject ?? '', years: []),
    );

    final courseId = int.tryParse(subject.id) ?? 0;

    Navigator.pop(context);
    // Navigate to study screen with API parameters
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CBTStudyScreen(
          subject: subject.name,
          topics: _selectedTopicNames,
          topicIds: _selectedTopicIds,
          courseId: courseId,
          examTypeId: widget.examTypeId,
        ),
      ),
    );
  }

  void _goBack() {
    if (_isSearching) {
      _toggleSearch();
      return;
    }
    if (_showTopics) {
      setState(() {
        _isTransitioning = true;
        _searchQuery = '';
        _searchController.clear();
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _showTopics = false;
            _selectedSubject = null;
            _selectedTopicIds = [];
            _selectedTopicNames = [];
            _expandedSyllabusIds.clear();
            _isTransitioning = false;
          });
        }
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_showTopics) {
          _goBack();
          return false;
        }
        return true;
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _goBack,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _isSearching
                        ? TextField(
                            controller: _searchController,
                            autofocus: true,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: _showTopics
                                  ? 'Search topics...'
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
                              color: AppColors.text4Light,
                            ),
                          )
                        : Text(
                            _showTopics ? 'Select Topic' : 'Select Subject',
                            style: AppTextStyles.normal600(
                              fontSize: 20,
                              color: AppColors.text4Light,
                            ),
                          ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isSearching ? Icons.close : Icons.search,
                      color: AppColors.text4Light,
                    ),
                    onPressed: _toggleSearch,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showTopics ? _buildTopicsList() : _buildSubjectsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsList() {
    // Create a sorted copy of the provided subjects (A -> Z) and display title-case names
    var sortedSubjects = List<SubjectModel>.from(widget.subjects)
      ..sort((a, b) => _titleCase(a.name).compareTo(_titleCase(b.name)));

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      sortedSubjects = sortedSubjects
          .where((s) => _titleCase(s.name).toLowerCase().contains(_searchQuery))
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
                  color: AppColors.text4Light,
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
      padding: const EdgeInsets.all(16),
      itemCount: sortedSubjects.length,
      itemBuilder: (context, index) {
        final subject = sortedSubjects[index];
        final color = _colorForId(subject.id);
        final displayName = _titleCase(subject.name);

        return GestureDetector(
          onTap: () => _onSubjectSelected(subject.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 12,
                    child: Text(
                      displayName.isNotEmpty ? displayName[0] : '?',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    displayName,
                    style: AppTextStyles.normal600(
                      fontSize: 18,
                      color: AppColors.text4Light,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopicsList() {
    final subject = widget.subjects.firstWhere((s) => s.id == _selectedSubject,
        orElse: () => SubjectModel(
            id: _selectedSubject ?? '',
            name: _selectedSubject ?? '',
            years: []));
    final subjectColor = _colorForId(subject.id);

    return Consumer<SubjectTopicsProvider>(
      builder: (context, topicsProvider, child) {
        // Loading state
        if (topicsProvider.loading) {
          return Container(
            color: subjectColor.withOpacity(0.05),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: subjectColor),
                  const SizedBox(height: 16),
                  Text(
                    'Loading topics...',
                    style: AppTextStyles.normal600(
                      fontSize: 16,
                      color: AppColors.text4Light,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Error state
        if (topicsProvider.error != null) {
          return Container(
            color: subjectColor.withOpacity(0.05),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Colors.red.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load topics',
                      style: AppTextStyles.normal600(
                        fontSize: 18,
                        color: AppColors.text4Light,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      topicsProvider.error ?? '',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.normal400(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _onSubjectSelected(_selectedSubject!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: subjectColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: AppTextStyles.normal600(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // No data
        var syllabuses = topicsProvider.topicsData?.data ?? [];
        if (syllabuses.isEmpty) {
          return Container(
            color: subjectColor.withOpacity(0.05),
            child: Center(
              child: Text(
                'No topics available',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }

        // Filter syllabuses and topics by search query
        if (_searchQuery.isNotEmpty) {
          syllabuses = syllabuses.where((syllabus) {
            final syllabusMatches =
                syllabus.syllabusName.toLowerCase().contains(_searchQuery);
            final hasMatchingTopics = syllabus.topics.any(
              (topic) => topic.topicName.toLowerCase().contains(_searchQuery),
            );
            return syllabusMatches || hasMatchingTopics;
          }).toList();
        }

        // Show empty state if no results after filtering
        if (syllabuses.isEmpty && _searchQuery.isNotEmpty) {
          return Container(
            color: subjectColor.withOpacity(0.05),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No topics found',
                      style: AppTextStyles.normal600(
                        fontSize: 18,
                        color: AppColors.text4Light,
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
            ),
          );
        }

        // Success - Display hierarchical syllabus/topics
        return Container(
          color: subjectColor.withOpacity(0.05),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: syllabuses.length,
                  itemBuilder: (context, index) {
                    final syllabus = syllabuses[index];
                    final isExpanded =
                        _expandedSyllabusIds.contains(syllabus.syllabusId);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                        children: [
                          // Syllabus header
                          InkWell(
                            onTap: () => _toggleSyllabus(syllabus.syllabusId),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  // Select all checkbox for syllabus
                                  if (isExpanded)
                                    GestureDetector(
                                      onTap: () => _toggleAllTopicsInSyllabus(
                                          syllabus.topics),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _areAllTopicsSelected(
                                                  syllabus.topics)
                                              ? subjectColor
                                              : subjectColor.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          _areAllTopicsSelected(syllabus.topics)
                                              ? Icons.check_box
                                              : _areSomeTopicsSelected(
                                                      syllabus.topics)
                                                  ? Icons
                                                      .indeterminate_check_box
                                                  : Icons
                                                      .check_box_outline_blank,
                                          color: _areAllTopicsSelected(
                                                  syllabus.topics)
                                              ? Colors.white
                                              : subjectColor,
                                          size: 20,
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: subjectColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.library_books,
                                        color: subjectColor,
                                        size: 20,
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          syllabus.syllabusName,
                                          style: AppTextStyles.normal600(
                                            fontSize: 16,
                                            color: AppColors.text4Light,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '${syllabus.topics.length} topics',
                                              style: AppTextStyles.normal400(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            if (isExpanded) ...[
                                              const SizedBox(width: 8),
                                              Text(
                                                _areAllTopicsSelected(
                                                        syllabus.topics)
                                                    ? 'Tap to deselect all'
                                                    : 'Tap to select all',
                                                style: AppTextStyles.normal400(
                                                  fontSize: 11,
                                                  color: subjectColor,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: subjectColor,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Topics list (expandable)
                          if (isExpanded)
                            Container(
                              decoration: BoxDecoration(
                                color: subjectColor.withOpacity(0.03),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                children: syllabus.topics.map((topic) {
                                  final isSelected =
                                      _selectedTopicIds.contains(topic.topicId);
                                  return InkWell(
                                    onTap: () => _onTopicSelected(topic),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 14),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: Colors.grey.shade200,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isSelected
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                            color: isSelected
                                                ? subjectColor
                                                : Colors.grey.shade400,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              topic.topicName,
                                              style: AppTextStyles.normal500(
                                                fontSize: 14,
                                                color: isSelected
                                                    ? subjectColor
                                                    : AppColors.text4Light,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Continue button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _selectedTopicIds.isNotEmpty ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: subjectColor,
                    disabledBackgroundColor: Colors.grey.shade300,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continue (${_selectedTopicIds.length} selected)',
                    style: AppTextStyles.normal600(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

