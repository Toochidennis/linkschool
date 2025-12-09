import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/cbt/cbt_study_screen.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';

class StudySubjectSelectionModal extends StatefulWidget {
  final List<SubjectModel> subjects;

  const StudySubjectSelectionModal({Key? key, required this.subjects}) : super(key: key);

  @override
  State<StudySubjectSelectionModal> createState() =>
      _StudySubjectSelectionModalState();
}

class _StudySubjectSelectionModalState
    extends State<StudySubjectSelectionModal> {
  String? _selectedSubject;
  List<String> _selectedTopics = [];
  bool _showTopics = false;
  bool _isTransitioning = false;


// Remove the map and just use a single list
final List<String> _staticTopics = [
  'Organic Chemistry',
  'Inorganic Chemistry',
  'Physical Chemistry',
  'Chemical Bonding',
  'Acids and Bases',
  'Redox Reactions',
  'Mechanics',
  'Electricity',
  'Magnetism',
  'Optics',
  'Thermodynamics',
  'Waves',
  'Cell Biology',
  'Genetics',
  'Ecology',
  'Human Anatomy',
  'Evolution',
  'Plant Biology',
  'Algebra',
  'Calculus',
  'Geometry',
  'Trigonometry',
  'Statistics',
  'Probability',
];
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

  void _onSubjectSelected(String subjectId) {
    setState(() {
      _selectedSubject = subjectId;
      _isTransitioning = true;
    });

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

  // Convert a string to sentence case: all lowercase then first letter uppercase
  String _sentenceCase(String input) {
    if (input.isEmpty) return input;
    final lower = input.toLowerCase();
    return lower[0].toUpperCase() + (lower.length > 1 ? lower.substring(1) : '');
  }

  void _onTopicSelected(String topic) {
    setState(() {
      if (_selectedTopics.contains(topic)) {
        _selectedTopics.remove(topic);
      } else {
        _selectedTopics.add(topic);
      }
    });
  }

  void _onContinue() {
    if (_selectedTopics.isNotEmpty) {
      final subject = widget.subjects.firstWhere(
        (s) => s.id == _selectedSubject,
        orElse: () => SubjectModel(id: _selectedSubject ?? '', name: _selectedSubject ?? '', years: []),
      );

      Navigator.pop(context);
      // Navigate to study screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CBTStudyScreen(
            subject: subject.name,
            topics: _selectedTopics,
          ),
        ),
      );
    }
  }

  void _goBack() {
    if (_showTopics) {
      setState(() {
        _isTransitioning = true;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _showTopics = false;
            _selectedSubject = null;
            _selectedTopics = [];
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
                  Text(
                    _showTopics ? 'Select Topic' : 'Select Subject',
                    style: AppTextStyles.normal600(
                      fontSize: 20,
                      color: AppColors.text4Light,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showTopics
                    ? _buildTopicsList()
                    : _buildSubjectsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsList() {
    // Create a sorted copy of the provided subjects (A -> Z) and display sentence-case names
    final sortedSubjects = List<SubjectModel>.from(widget.subjects)
      ..sort((a, b) => _sentenceCase(a.name).compareTo(_sentenceCase(b.name)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedSubjects.length,
      itemBuilder: (context, index) {
        final subject = sortedSubjects[index];
        final color = _colorForId(subject.id);
        final displayName = _sentenceCase(subject.name);

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
                    child: Text(
                      displayName.isNotEmpty ? displayName[0] : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    radius: 12,
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
    final topics = _staticTopics;
    final subject = widget.subjects.firstWhere((s) => s.id == _selectedSubject, orElse: () => SubjectModel(id: _selectedSubject ?? '', name: _selectedSubject ?? '', years: []));
    final subjectColor = _colorForId(subject.id);

    return Container(
      color: subjectColor.withOpacity(0.05),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];
                final isSelected = _selectedTopics.contains(topic);

                return GestureDetector(
                  onTap: () => _onTopicSelected(topic),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? subjectColor.withOpacity(0.15)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      // border: Border.all(
                      //   color: isSelected ? subjectColor : Colors.grey.shade300,
                      //   width: isSelected ? 2 : 1,
                      // ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isSelected ? subjectColor : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            topic,
                            style: AppTextStyles.normal600(
                              fontSize: 16,
                              color: isSelected ? subjectColor : AppColors.text4Light,
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
              onPressed: _selectedTopics.isNotEmpty ? _onContinue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: subjectColor,
                disabledBackgroundColor: Colors.grey.shade300,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Continue',
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
  }
}