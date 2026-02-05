import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/cbt/cbt_games/game_instruction.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';
import 'package:linkschool/modules/services/cbt_subscription_service.dart';
import 'package:linkschool/modules/services/firebase_auth_service.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/explore/e_library/widgets/subscription_enforcement_dialog.dart';
import 'package:linkschool/modules/common/cbt_settings_helper.dart';
import 'package:linkschool/modules/providers/explore/subject_topic_provider.dart';
import 'package:linkschool/modules/model/explore/study/topic_model.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class GameSubjectModal extends StatefulWidget {
  final List<SubjectModel> subjects;
  final int examTypeId;

  const GameSubjectModal({
    super.key,
    required this.subjects,
    required this.examTypeId,
  });

  @override
  State<GameSubjectModal> createState() => _GameSubjectModalState();
}

class _GameSubjectModalState extends State<GameSubjectModal>
    with TickerProviderStateMixin {
  String? _selectedSubject;
  List<int> _selectedTopicIds = [];
  List<String> _selectedTopicNames = [];
  bool _showTopics = false;
  bool _isTransitioning = false;
  final Set<int> _expandedSyllabusIds = {};
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late AnimationController _slideController;

  // Search state
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final _subscriptionService = CbtSubscriptionService();
  final _authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sparkleController.dispose();
    _slideController.dispose();
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

  // Deterministic color selection for subject ids (same as study modal)
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

  // Get emoji based on subject name (fallback for missing emojis)
  String _emojiForSubject(String subjectName) {
    final name = subjectName.toLowerCase();
    if (name.contains('chem')) return '⚗️';
    if (name.contains('phys')) return '⚡';
    if (name.contains('bio')) return '🧬';
    if (name.contains('math')) return '🔢';
    if (name.contains('english')) return '📚';
    if (name.contains('geo')) return '🌍';
    if (name.contains('history')) return '📜';
    if (name.contains('art')) return '🎨';
    if (name.contains('music')) return '🎵';
    if (name.contains('computer')) return '💻';
    if (name.contains('science')) return '🔬';
    if (name.contains('french') ||
        name.contains('spanish') ||
        name.contains('language')) {
      return '🗣️';
    }
    return '📚'; // Default emoji
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

    _slideController.reset();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showTopics = true;
          _isTransitioning = false;
        });
        _slideController.forward();
      }
    });
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
    if (_selectedTopicIds.isEmpty) return;

    // ⚡ Gamify Module: Check subscription with free trial tracking
    final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
    final hasUserPaid = userProvider.hasPaid;
    final canTakeTest = await _subscriptionService.canTakeTest();
    final remainingTests = await _subscriptionService.getRemainingFreeTests();

    print('\n🎮 Gamify Module Access Check:');
    print('   - Backend says paid: $hasUserPaid');
    print('   - Local says can take test: $canTakeTest');
    print('   - Remaining free tests: $remainingTests');

    // If backend confirms payment, allow access
    if (hasUserPaid) {
      print('   ✅ User has paid (verified from backend) - starting game');
      _proceedWithGame();
      return;
    }

    // If not paid, show prompt (hard if trial expired)
    final trialExpired = await _subscriptionService.isTrialExpired();
    final settings = await CbtSettingsHelper.getSettings();
    if (!mounted) return;

    // if (!canTakeTest || trialExpired) {
    //   print('   ❌ Gamify access denied - showing enforcement dialog');
    //   final allowProceed = await showDialog<bool>(
    //     context: context,
    //     barrierDismissible: true,
    //     builder: (context) => SubscriptionEnforcementDialog(
    //       isHardBlock: true,
    //       remainingTests: remainingTests,
    //       amount: settings.amount,
    //       discountRate: settings.discountRate,
    //       onSubscribed: () async {
    //         print('✅ User subscribed from Gamify module');
    //         await userProvider.refreshCurrentUser();
    //         if (mounted) {
    //           setState(() {});
    //         }
    //       },
    //     ),
    //   );
    //   if (allowProceed == true) {
    //     _proceedWithGame();
    //   }
    //   return;
    // }

    // Within trial: show soft prompt and allow proceed
    final allowProceed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => SubscriptionEnforcementDialog(
        isHardBlock: false,
        remainingTests: remainingTests,
        amount: settings.amount,
        discountRate: settings.discountRate,
        onSubscribed: () async {
          print('✅ User subscribed from Gamify module');
          await userProvider.refreshCurrentUser();
          if (mounted) {
            setState(() {});
          }
        },
      ),
    );

    if (allowProceed == true) {
      print('   ✅ User can access game (within free limit)');
      _proceedWithGame();
    }
  }

  void _proceedWithGame() {
    final subject = widget.subjects.firstWhere(
      (s) => s.id == _selectedSubject,
      orElse: () => SubjectModel(
          id: _selectedSubject ?? '', name: _selectedSubject ?? '', years: []),
    );

    final courseId = int.tryParse(subject.id) ?? 0;

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameInstructionsScreen(
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

  // Convert a string to title case: capitalize first letter of every word
  String _titleCase(String input) {
    if (input.isEmpty) return input;
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              _showTopics
                  ? _colorForId(_selectedSubject ?? '').withOpacity(0.08)
                  : Colors.grey.shade50,
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Stack(
          children: [
            // Animated background particles
            AnimatedBuilder(
              animation: _sparkleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(_sparkleController.value),
                  size: Size.infinite,
                );
              },
            ),
            Column(
              children: [
                // Header with game-style design
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _goBack,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
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
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _showTopics
                                        ? 'Choose Your Topics'
                                        : 'Pick a Subject',
                                    style: AppTextStyles.normal600(
                                      fontSize: 20,
                                      color: AppColors.text4Light,
                                    ),
                                  ),
                                  Text(
                                    _showTopics
                                        ? '${_selectedTopicIds.length} selected'
                                        : 'Start your learning adventure',
                                    style: AppTextStyles.normal400(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
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
                      const SizedBox(width: 8),
                      if (_showTopics && _selectedSubject != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _colorForId(_selectedSubject!),
                                _colorForId(_selectedSubject!).withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: _colorForId(_selectedSubject!)
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '⭐',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_selectedTopicIds.length * 10}',
                                style: AppTextStyles.normal600(
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

                // Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child:
                        _showTopics ? _buildTopicsList() : _buildSubjectsList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsList() {
    // Create a sorted copy of the provided subjects (A -> Z) with title-case names
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
        final subjectColor = _colorForId(subject.id);
        final displayName = _titleCase(subject.name);
        final emoji = _emojiForSubject(subject.name);

        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onTap: () => _onSubjectSelected(subject.id),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        subjectColor.withOpacity(0.15),
                        subjectColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: subjectColor.withOpacity(0.3),
                        blurRadius: 12 + (_pulseController.value * 4),
                        offset: Offset(0, 4 + (_pulseController.value * 2)),
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Hero(
                      tag: 'game_subject_${subject.id}',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              subjectColor,
                              subjectColor.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: subjectColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: AppTextStyles.normal600(
                              fontSize: 18,
                              color: AppColors.text4Light,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to explore',
                            style: AppTextStyles.normal400(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: subjectColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: subjectColor,
                        size: 18,
                      ),
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

  Widget _buildTopicsList() {
    final subject = widget.subjects.firstWhere((s) => s.id == _selectedSubject,
        orElse: () => SubjectModel(
            id: _selectedSubject ?? '',
            name: _selectedSubject ?? '',
            years: []));
    final subjectColor = _colorForId(subject.id);
    final displayName = _titleCase(subject.name);

    return Consumer<SubjectTopicsProvider>(
      builder: (context, topicsProvider, child) {
        // Loading state
        if (topicsProvider.loading) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  subjectColor.withOpacity(0.05),
                  Colors.white,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: subjectColor),
                  const SizedBox(height: 16),
                  Text(
                    'Loading game topics...',
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  subjectColor.withOpacity(0.05),
                  Colors.white,
                ],
              ),
            ),
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  subjectColor.withOpacity(0.05),
                  Colors.white,
                ],
              ),
            ),
            child: Center(
              child: Text(
                'No topics available',
                style: AppTextStyles.normal600(
                  fontSize: 25,
                  color: Colors.white,
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  subjectColor.withOpacity(0.05),
                  Colors.white,
                ],
              ),
            ),
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

        // Success - Display hierarchical syllabus/topics with game UI
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                subjectColor.withOpacity(0.05),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            children: [
              // Subject header in topics view
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: subjectColor.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(color: subjectColor.withOpacity(0.2)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: subjectColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _emojiForSubject(displayName),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      displayName,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.normal600(
                        fontSize: 16,
                        color: AppColors.text4Light,
                      ),
                    ),
                  ],
                ),
              ),

              // Syllabus list with expandable topics
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: syllabuses.length,
                  itemBuilder: (context, index) {
                    final syllabus = syllabuses[index];
                    final isExpanded =
                        _expandedSyllabusIds.contains(syllabus.syllabusId);

                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _slideController,
                        curve: Interval(
                          (index * 0.1).clamp(0.0, 1.0),
                          ((index + 1) * 0.1).clamp(0.0, 1.0),
                          curve: Curves.easeOut,
                        ),
                      )),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: subjectColor.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Syllabus header (clickable to expand)
                            InkWell(
                              onTap: () => _toggleSyllabus(syllabus.syllabusId),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      subjectColor.withOpacity(0.1),
                                      subjectColor.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: isExpanded
                                      ? const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        )
                                      : BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    // Select all checkbox for syllabus (when expanded)
                                    if (isExpanded)
                                      GestureDetector(
                                        onTap: () => _toggleAllTopicsInSyllabus(
                                            syllabus.topics),
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: _areAllTopicsSelected(
                                                      syllabus.topics)
                                                  ? [
                                                      Colors.green,
                                                      Colors.green.shade600
                                                    ]
                                                  : [
                                                      subjectColor,
                                                      subjectColor
                                                          .withOpacity(0.7)
                                                    ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: (_areAllTopicsSelected(
                                                            syllabus.topics)
                                                        ? Colors.green
                                                        : subjectColor)
                                                    .withOpacity(0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            _areAllTopicsSelected(
                                                    syllabus.topics)
                                                ? Icons.check_box
                                                : _areSomeTopicsSelected(
                                                        syllabus.topics)
                                                    ? Icons
                                                        .indeterminate_check_box
                                                    : Icons
                                                        .check_box_outline_blank,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              subjectColor,
                                              subjectColor.withOpacity(0.7),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.library_books,
                                          color: Colors.white,
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
                                              fontSize: 15,
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
                                              const SizedBox(width: 8),
                                              if (isExpanded)
                                                Text(
                                                  _areAllTopicsSelected(
                                                          syllabus.topics)
                                                      ? 'Tap to deselect all'
                                                      : 'Tap to select all',
                                                  style:
                                                      AppTextStyles.normal400(
                                                    fontSize: 10,
                                                    color: subjectColor,
                                                  ),
                                                )
                                              else
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: subjectColor
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Text(
                                                    '+${syllabus.topics.length * 10} ⭐',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: subjectColor,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    AnimatedRotation(
                                      turns: isExpanded ? 0.5 : 0,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: Icon(
                                        Icons.expand_more,
                                        color: subjectColor,
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Expanded topics list
                            if (isExpanded)
                              Container(
                                decoration: BoxDecoration(
                                  color: subjectColor.withOpacity(0.03),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                child: Column(
                                  children: syllabus.topics.map((topic) {
                                    final isSelected = _selectedTopicIds
                                        .contains(topic.topicId);
                                    return InkWell(
                                      onTap: () => _onTopicSelected(topic),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? subjectColor.withOpacity(0.1)
                                              : null,
                                          border: Border(
                                            top: BorderSide(
                                              color: Colors.grey.shade200,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              padding: EdgeInsets.all(
                                                  isSelected ? 2 : 0),
                                              decoration: BoxDecoration(
                                                gradient: isSelected
                                                    ? LinearGradient(
                                                        colors: [
                                                          subjectColor,
                                                          subjectColor
                                                              .withOpacity(0.7),
                                                        ],
                                                      )
                                                    : null,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                isSelected
                                                    ? Icons.check_circle
                                                    : Icons
                                                        .radio_button_unchecked,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey.shade400,
                                                size: 22,
                                              ),
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
                                            if (isSelected)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: subjectColor,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '+10 ⭐',
                                                  style:
                                                      AppTextStyles.normal600(
                                                    fontSize: 10,
                                                    color: Colors.white,
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
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _selectedTopicIds.isNotEmpty
                          ? 1.0 + (_pulseController.value * 0.02)
                          : 1.0,
                      child: child,
                    );
                  },
                  child: ElevatedButton(
                    onPressed:
                        _selectedTopicIds.isNotEmpty ? _onContinue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: subjectColor,
                      disabledBackgroundColor: Colors.grey.shade300,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: _selectedTopicIds.isNotEmpty ? 8 : 0,
                      shadowColor: subjectColor.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _selectedTopicIds.isEmpty
                              ? 'Select topics to continue'
                              : 'Start Game (${_selectedTopicIds.length} topics)',
                          style: AppTextStyles.normal600(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        if (_selectedTopicIds.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.rocket_launch,
                              color: Colors.white, size: 20),
                        ],
                      ],
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

// Custom painter for particle effects
class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final random = math.Random(42);

    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final y = baseY + (animationValue * 50) % size.height;

      final opacity = (math.sin(animationValue * math.pi * 2 + i) + 1) / 2;
      paint.color = Colors.blue.withOpacity(opacity * 0.15);

      canvas.drawCircle(
        Offset(x, y % size.height),
        2 + (random.nextDouble() * 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

